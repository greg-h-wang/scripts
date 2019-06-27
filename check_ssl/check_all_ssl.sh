#! /bin/bash

Alert_Email="wanghuan@baixing.com"
Cur_Dir=$(dirname $0)

baixing_live=(www.baixing.live vip.baixing.live guang-staging.baixing.live)
baixingeg_com=(www.baixingeg.com)

CleanFiles()
{
    cd "$(dirname "$0")"; pwd
    ls * |grep csv > /dev/null 2>&1
    if [ $? = 0 ];then
	echo "Cleaning old data"
        rm -f *.csv
        echo "Clean done. Let's do it!"
    else
        echo "Let's do it!"
    fi
}

CheckSSL()
{
    Expire_Date=$(echo | openssl s_client -servername ${Domain}  -connect ${Domain}:443 2>/dev/null | openssl x509 -noout -dates |grep 'After'| awk -F '=' '{print $2}')
    #Expire_Date=$(curl -o /dev/null -m 10 --connect-timeout 10 -svIL https://${Domain} 2>&1|grep "expire date:"|sed 's/*\s\+expire date:\s\+//')
    echo "${Domain}, ${Expire_Date}" >> ${Cur_Dir}/${List}.csv 2>&1
}

CleanFiles
for List in {baixing_live,baixingeg_com,baixing_com_cn,baixing_cn,baixing_com,baixing_net} ; do
    echo "收集 ${List} 部分..."
    echo "域名, 证书过期时间" >> ${Cur_Dir}/${List}.csv
    for Domain in $(eval echo \${$List[@]}) ; do
	CheckSSL
    done
done

if  [ ${Alert_Email} != "" ] ; then
    echo "发送邮件报告中..."
    sendemail -o tls=yes -f "wanghuan@baixing.com" -t "wanghuan@baixing.com" -t ${Alert_Email} -s smtp.partner.outlook.cn:587 -xu wanghuan@baixing.com -xp 'password' -u "各域名证书过期时间统计" -o message-content-type=html -o message-charset=utf8 -m "Hey Guys,<br/><br/><br/> 这是一封机器人邮件，脚本每天遍历一遍百姓网所有域名。统计结果可通过附件查看。<br/><br/>P.S.  若附件中【证书过期时间】一列为空，则表示此域名并没有启用https。<br/> <br/><p>此邮件为定时任务，请勿回复，谢谢！<p>" -a ${Cur_Dir}/*.csv >/dev/null 2>&1
    echo "邮件发送完成"
fi
