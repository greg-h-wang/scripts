set -e # jenkins shell 插件默认，命令执行失败则退出而不是继续执行
set +x

AppOrg="$1"
AppEnv="$2"
AppName="$3"
AppAddresses="$4"
ToImage="$5"
GitBranch="$6"
RunOptions="$(echo '' $7 | tr '\n' ' ')"
RunCmd="$8"
ACTION="$(echo '' $9 | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')"
HealthCheckURL="${10}"
CfgLabelBaseNode="${11}"
LogBasePath="${12}"
DOCKER_REGISTRY="${13}"
NoCache="${14}"
FromImage="${15}"
Dockerfile="${16}"
BuildCmd="${17}"
WORKSPACE="${18}"
TarCmd="${19}"

# 如果参数不存在，Managed Scripts 插件不会对变量进行解释，
# 而是直接传递过来，形如：${VAR1}。
# 这里把这样的参数处理成空：export VAR1=""，
# 为下面兼容多版本做支撑
while (($# > 0)); do
    echo "$1" | grep -qE '^\$\{[a-zA-Z]*\}' && _RET=0 || _RET=1
    if [ $_RET -eq 0 ]; then
        _var=${1#$\{}
        _var=${_var%\}}
        eval 'export ${_var}=""'
    fi
    shift
done


# 发布前的清理工作
clean() {
    echo "Clean temp status directory"
    rm -rf ${WORKSPACE}/tmp.*
}


# 编译代码，制作镜像
build() {
    if [ "x${ACTION}" == "xDEPLOY" ] || [ "x${ACTION}" == "xPRE_DEPLOY" ]; then
        echo -e "\n测试 docker 仓库: ${DOCKER_REGISTRY}"
        curl --connect-timeout 30 -I ${DOCKER_REGISTRY} 2>/dev/null | grep 'HTTP/1.1 200 OK' > /dev/null

        echo -e "\n检查镜像是否已经存在: ${ToImage}"
        Image_Check=$(echo ${ToImage} | sed 's/\([^/]\+\)\([^:]\+\):/\1\/v2\2\/manifests\//')
        Responed_Code=$(curl  -so /dev/null -w '%{response_code}' ${Image_Check} || true)
        if [ "${NoCache}" == "true" ] || [ "x${Responed_Code}" != "x200" ] ; then
           if [  "x${BuildCmd}" ==  "x"  ]; then
               echo -e "\n生成Dockerfile文件"
               echo "FROM ${FromImage}" > Dockerfile
               cat >> Dockerfile <<- EOF
               ${Dockerfile}
EOF
               echo "$(<Dockerfile)"
           else
               echo -e "\n编译代码\n${BuildCmd}"
               eval ${BuildCmd}

               echo -e "\n打包代码\n${TarCmd}"
               cd ${WORKSPACE}
               eval ${TarCmd}

               echo -e "\n复制代码包: ${CodeTarget}"
               cd ${WORKSPACE}
               if [ $(expr match "${CodeTarget}" '.*/') -ne 0 ];then
                 CodeBasename=${CodeTarget##*/}
                 cp -av ${CodeTarget} ${CodeBasename}
               else
                 CodeBasename=${CodeTarget}
               fi
               echo "CodeBasename=#${CodeBasename}#"

               echo -e "\n生成Dockerfile文件"
               cat > Dockerfile <<- EOF
               FROM ${FromImage}
               MAINTAINER devops <devops@dianrong.com>
               ADD ${CodeBasename} \${AppCode}
EOF
               echo "$(<Dockerfile)"
            fi

            echo -e "\n同步上层镜像: ${FromImage}"
            docker pull ${FromImage} # 同步上层镜像
            
            echo -e "\n构建镜像，并Push到仓库: ${ToImage}"
            docker build --no-cache=${NoCache} -t ${ToImage} . && docker push ${ToImage} || exit 1 # 开始构建镜像，成功后Push到仓库
            
            echo -e "\n删除镜像: ${ToImage}"
            docker rmi ${ToImage} || echo # 删除镜像
        fi
    fi
}


# 健康检查，如果失败则返回 1，进而会直接结束程序
check_url() {
    CHECK_URL="$1"
    RETRY_COUNT=20
    TIMEOUT=60

    echo "CHECK URL: $CHECK_URL"

    while (($RETRY_COUNT > 0)); do
        http_code=$(curl -sL -w "%{http_code}" --connect-timeout $TIMEOUT --max-time $TIMEOUT -o /dev/null "$CHECK_URL" || true)
        if [ "x$http_code" == "x000" ]; then
            echo "[$(date '+%F %T')] Connection refused, wait 10s and retry #$RETRY_COUNT# $CHECK_URL"
            let  RETRY_COUNT-- || true
            sleep 10
        elif [ "x$http_code" == "x200" ]; then
            echo "Health check successed"
            break
        elif [ "x$http_code" == "x405" ]; then
            echo "GET method not allowed, try HEAD method"
            http_code=$(curl -sL -I -w "%{http_code}" --connect-timeout $TIMEOUT --max-time $TIMEOUT -o /dev/null "$CHECK_URL" || true)
            if [ "x$http_code" == "x200" ]; then
                echo "Health check successed"
                break
            else
                echo "[$(date '+%F %T')] NOT expected http code: $http_code"
                return 1
            fi
        else
            echo "[$(date '+%F %T')] NOT expected http code: $http_code"
            return 1
        fi
    done

    [ $RETRY_COUNT -eq 0 ] && { echo "Health Check Failed"; _RET=1; } || _RET=0

    return $_RET
}


enable_zabbix_monitoring() {
    local _AppOrg=$(echo "${AppOrg}" | tr "[:upper:]" "[:lower:]")
    local _AppEnv=$(echo "${AppEnv}" | tr "[:upper:]" "[:lower:]")
    local _AppName="ZABBIX"
    local _CFG_ADDR="x"
    local _CFG_LABEL="x"
    local _ITEM_NAME="$1"

    case ${_AppEnv} in
        prod)
            _CFG_ADDR="1.common.zookeeper.prod.sl.com:2181,2.common.zookeeper.prod.sl.com:2181,3.common.zookeeper.prod.sl.com:2181"
            _CFG_LABEL=$(echo "${_AppOrg}_${_AppEnv}_${_AppName}" | tr "[:lower:]" "[:upper:]")
            ;;
        *)
            echo "Invalid AppEnv: ${AppEnv}"
            return 1
            ;;
    esac

    echo "启用监控"
    docker run --rm \
        -e CFG_ADDR=${_CFG_ADDR} \
        -e CFG_FILES=zabbix.conf \
        -e CFG_LABEL=${_CFG_LABEL} \
        ${DOCKER_REGISTRY}/base/utils/zabbix-cli:1.0 enable "${_ITEM_NAME}" || true
}


disable_zabbix_monitoring() {
    local _AppOrg=$(echo "${AppOrg}" | tr "[:upper:]" "[:lower:]")
    local _AppEnv=$(echo "${AppEnv}" | tr "[:upper:]" "[:lower:]")
    local _AppName="ZABBIX"
    local _CFG_ADDR="x"
    local _CFG_LABEL="x"
    local _ITEM_NAME="$1"

    case ${_AppEnv} in
        prod)
            _CFG_ADDR="1.common.zookeeper.prod.sl.com:2181,2.common.zookeeper.prod.sl.com:2181,3.common.zookeeper.prod.sl.com:2181"
            _CFG_LABEL=$(echo "${_AppOrg}_${_AppEnv}_${_AppName}" | tr "[:lower:]" "[:upper:]")
            ;;
        *)
            echo "Invalid AppEnv: ${AppEnv}"
            return 1
            ;;
    esac

    echo "禁用监控"
    docker run --rm \
        -e CFG_ADDR=${_CFG_ADDR} \
        -e CFG_FILES=zabbix.conf \
        -e CFG_LABEL=${_CFG_LABEL} \
        ${DOCKER_REGISTRY}/base/utils/zabbix-cli:1.0 disable "${_ITEM_NAME}" || true
}


# 发布、预发布、停止、重启
deploy() {
    AppAddress="$1"

    # 初始化变量
    ADDRESS=${AppAddress%%,*} # 宿主机地址和宿主机端口
    AppExpose=`echo ,${AppAddress#*,} | sed 's/,/ -p /g'` # 需要影射的端口
    AppIp=${ADDRESS%%_*} # 宿主机地址
    AppPort=${ADDRESS##*_} # 宿主机端口
    AppId=`echo ${AppOrg}_${AppEnv}_${AppName}_${AppIp}_${AppPort} | sed 's/[^a-zA-Z0-9_]//g' | tr "[:lower:]" "[:upper:]"` # 实例Id/容器名
    AppHostname=`echo ${AppPort}-${AppIp}-${AppName}-${AppEnv}-${AppOrg} | sed 's/[^a-zA-Z0-9-]//g'| tr "[:upper:]" "[:lower:]"` # 实例主机名
    RunImage=${ToImage%:*}:${GitBranch##*/} # 版本镜像

    JmxPort=$(( AppPort + 10 ))
    
    echo "同步 zabbix-cli 镜像"
    docker pull ${DOCKER_REGISTRY}/base/utils/zabbix-cli:1.0 > /dev/null

    if [ "x${ACTION}" == "xSTOP" ]; then
        # 停止当前实例
        disable_zabbix_monitoring ${AppId}
        docker -H ${AppIp}:4243 stop ${AppId}
    elif [ "x${ACTION}" == "xRESTART" ]; then
        disable_zabbix_monitoring ${AppId}
        docker -H ${AppIp}:4243 restart ${AppId}

        if [ "x$HealthCheckURL" != "x" ]; then
            check_url "${AppIp}:${AppPort}${HealthCheckURL}"
        else
            sleep 10
        fi
        enable_zabbix_monitoring ${AppId}
    else
        docker -H ${AppIp}:4243 pull ${ToImage} >/dev/null # 同步版本镜像
        if [ "x${ACTION}" == "xPRE_DEPLOY" ]; then
            echo " ${AppIp}:${AppPort}  PreDeployed"
            return 0
        fi

        docker -H ${AppIp}:4243 tag ${ToImage} ${RunImage} # 新增镜像Tag
        RESULT=`docker -H ${AppIp}:4243 inspect -f '{{.Image}}' ${AppId} || echo 0` # 保留当前实例的镜像Id
        disable_zabbix_monitoring ${AppId}
        docker -H ${AppIp}:4243 stop ${AppId} || echo # 停止当前实例
        docker -H ${AppIp}:4243 rm ${AppId} || echo # 删除当前实例


        if [ "x${CfgLabelBaseNode}" != "x" ] && [ "x${LogBasePath}" != "x" ] ; then

            echo "Run Docker Container the new style"

            set -x
            eval "docker -H ${AppIp}:4243 run -d --name=${AppId} --hostname=${AppHostname} \
            -e CFG_LABEL=${CfgLabelBaseNode}/${AppId%_*_*} \
            -e JmxPort=${JmxPort} \
            -e JMX_PORT=${JmxPort} \
            -e JMX_IP=${AppIp} \
            -p ${JmxPort}:${JmxPort} \
            -e AppAddress=${AppIp}:${AppPort} \
            -e AppIp=${AppIp} \
            -e AppPort=${AppPort} \
            -v ${LogBasePath}/${AppId}:/volume_logs -e UMASK=0022 \
            ${AppExpose} ${RunOptions} ${RunImage} ${RunCmd}"
            set +x
        else
            echo "Run Docker Container the old style"
            
            set -x
            eval "docker -H ${AppIp}:4243 run --name=${AppId} --hostname=${AppHostname} \
            -e AppId=${AppId} \
            -e JmxPort=${JmxPort} \
            -e JMX_PORT=${JmxPort} \
            -e JMX_IP=${AppIp} \
            -p ${JmxPort}:${JmxPort} \
            -e AppAddress=${AppIp}:${AppPort} \
            -e AppIp=${AppIp} \
            -e AppPort=${AppPort} \
            ${AppExpose} ${RunOptions} ${RunImage} ${RunCmd}"
            set +x

        fi

        if [ "x$HealthCheckURL" != "x" ]; then
            check_url "${AppIp}:${AppPort}${HealthCheckURL}"
        else
            sleep 10
        fi
        enable_zabbix_monitoring ${AppId}

        docker -H ${AppIp}:4243 rmi ${RESULT} || echo # 删除之前的镜像
    fi
}


# 编译
build

# 发布前的清理工作
clean

# 并行发布
# (1) 先发布一个实例
# (2) 如果发布成功，则剩下的采取分批并行发布，否则直接失败退出

STATUS_DIR=$(mktemp -d -p "${WORKSPACE}")
AppAddresses=($AppAddresses)
declare -i index=0 # 数组元素索引
declare -i count=${#AppAddresses[@]} # 数组长度
declare -i parallel_num=0 # 并行个数

# 计算并行个数
if [ "x${ACTION}" == "xSTOP" ] || [ "x${ACTION}" == "xPRE_DEPLOY" ]; then
    echo -e "\nSTOP 和 PRE_DEPLOY 操作全量并行"
    let parallel_num=count || true
else
    _upper_app_name=`echo ${AppName} | tr "[:lower:]" "[:upper:]"`
    if [ "x${_upper_app_name}" == "xMAINAPP" ]; then
        # mainapp 特殊处理，最大并发 2 个
        echo -e "\nMainApp 最大并发 2 个"
        parallel_num=2
    else
        # 其他情况每次并发一半
        let parallel_num="(count + 1) / 2" || true # 根据任务数量计算并发数，最大并行数量是总任务个数的一半
        if ((parallel_num == 0)); then
            let parallel_num=count || true
        fi
    fi
fi

cat <<-EOF
#####################################################
#
#          并行发布
#
#####################################################
地址列表: #${AppAddresses[@]}#
实例数: #${count}#
并行数量: #${parallel_num}#

EOF

while ((index < count)); do
    if ((index == 0)); then
        echo "[$index] First ${ACTION}: -------------------- #${AppAddresses[$index]}# --------------------"
        deploy "${AppAddresses[$index]}"
        let index++ || true
    else
        for ((i=0; i < parallel_num; i++)); do
            if ((index >= count)); then
                echo 0 > "${STATUS_DIR}/$i"
                continue
            fi

            #
            # 初始化任务执行结果为失败
            # 如果子任务执行成功，则会在子任务的最后把状态置为成功
            #
            # 放在子任务外以防止磁盘空间导致的初始状态操作失败
            # 由于 set -e，如果操作失败则直接退出
            #            
            echo 1 > "${STATUS_DIR}/$i"

            {
                # 在子进程中运行
                set -e # 子进程中的任一命令执行失败则退出

                echo "[$index] Parallel ${ACTION}: -------------------- #${AppAddresses[$index]}#, task-id: #$i# --------------------"
                deploy "${AppAddresses[$index]}"

                echo 0 > "${STATUS_DIR}/$i" # 如果任务执行成功，则可以正常重置任务状态
            } &
            let index++ || true
        done

        # 等待所有子任务结束
        echo "Waiting parallel child process finished..."
        wait

        # 检查子任务返回状态
        for ((i=0; i < parallel_num; i++)); do
            let status="$(<${STATUS_DIR}/$i) + status" || true
            if ((status > 0)); then
                echo "[ERROR] Parallel failed: status: #$status#"
                exit $status
            fi
        done
    fi
done

