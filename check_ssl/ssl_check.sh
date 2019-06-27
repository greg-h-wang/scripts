#! /bin/bash

Alert_Email="server@baixing.com"
Cur_Dir=$(dirname $0)
Alert_Days="30"

baixing_live=(www.baixing.live vip.baixing.live guang-staging.baixing.live)
baixingeg_com=(www.baixingeg.com)

CleanFiles()
{
    cd "$(dirname "$0")"; pwd
    ls * |grep message.txt > /dev/null 2>&1
    if [ $? = 0 ];then
	echo "Cleaning old data"
        rm -f ${Cur_Dir}/message.txt
        echo "Clean done. Let's do it!"
    else
        echo "Let's do it!"
    fi
}

CheckSSL()
{
    Current_Timestamp=$(date +%s)
    Expire_Date=$(timeout 2 bash -c "echo | openssl s_client -servername ${Domain} -connect ${Domain}:443 2>/dev/null | openssl x509 -noout -dates |grep 'After'" | awk -F '=' '{print $2}')
    Expire_Timestamp=$(date -d "${Expire_Date}" +%s)
    Alert_Timestamp=$((${Expire_Timestamp}-${Alert_Days}*86400))
    Days_Remaining_Timestamp=$((${Expire_Timestamp}-${Current_Timestamp}))
    Days_Remaining_Timestamp_readable=$(eval "echo ${Days_Remaining_Timestamp}/86400 | bc")

    if  [ -n "${Expire_Date}" ] && [ ${Days_Remaining_Timestamp_readable} -ge 0 ] && [ ${Current_Timestamp} -ge ${Alert_Timestamp} ] ; then
	echo "域名:${Domain},  剩余过期天数:${Days_Remaining_Timestamp_readable} <br/><br/>" >> ${Cur_Dir}/message.txt 2>&1
    fi
}

CleanFiles
for List in {baixing_live,baixingeg_com,baixing_com_cn,baixing_cn,baixing_com,baixing_net} ; do
    echo "收集 ${List} 部分..."
    for Domain in $(eval echo \${$List[@]}) ; do
	CheckSSL
    done
done

if  [ ${Alert_Email} != "" ] ; then
    echo "发送邮件报告中..."
    sendemail -o tls=yes -f "wanghuan@baixing.com" -t ${Alert_Email} -t wanghuan@baixing.com -s smtp.partner.outlook.cn:587 -xu wanghuan@baixing.com -xp 'password' -u "${Alert_Days}天内证书过期域名清单" -o message-content-type=html -o message-charset=utf8 -m `cat  ${Cur_Dir}/message.txt` >/dev/null 2>&1
    echo "邮件发送完成"
fi
