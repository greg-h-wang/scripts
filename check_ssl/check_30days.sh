#! /bin/bash

domain_list_api='https://dnsapi.cn/Domain.List'
record_list_api='https://dnsapi.cn/Record.List'
api_token='105242,abd773c72334de655c124c72c5733158'
Alert_Email="server@baixing.com"
Alert_Days="30"


CheckSSL()
{
    Current_Timestamp=$(date +%s)
    Expire_Date=$(timeout 2 bash -c "echo | openssl s_client -servername ${check_record} -connect ${check_record}:443 2>/dev/null | openssl x509 -noout -dates |grep 'After'" | awk -F '=' '{print $2}')
    Expire_Timestamp=$(date -d "${Expire_Date}" +%s)
    Alert_Timestamp=$((${Expire_Timestamp}-${Alert_Days}*86400))
    Days_Remaining_Timestamp=$((${Expire_Timestamp}-${Current_Timestamp}))
    Days_Remaining_Timestamp_readable=$(eval "echo ${Days_Remaining_Timestamp}/86400 | bc")

    if  [ -n "${Expire_Date}" ] && [ ${Days_Remaining_Timestamp_readable} -ge 0 ] && [ ${Current_Timestamp} -ge ${Alert_Timestamp} ] ; then
        echo "域名:${check_record},  剩余过期天数:${Days_Remaining_Timestamp_readable} <br/><br/>" >> tmp/message.txt 2>&1
    fi
}

CheckCache()
{
    if [ ! -d tmp ] ; then
      mkdir tmp
    else
      ls tmp/* > /dev/null 2>&1
      if [ $? = 0 ];then
          echo "Cleaning old data"
          rm -rf tmp/*
          echo "Clean done. Let's do it!"
      else
          echo "Let's do it!"
      fi
    fi
}

####################### script body ######################

CheckCache

for domain_id in $(curl -s -X POST ${domain_list_api} -d "login_token=${api_token}&format=json" |python -mjson.tool |grep "id" |grep -v group_id | awk -F : '{print $2}' | awk -F ',' '{print $1}') ; do
  curl -s -X POST ${record_list_api} -d "login_token=${api_token}&format=json&domain_id=${domain_id}" |python -mjson.tool > tmp/${domain_id}

  domain_name=$(grep punycode tmp/${domain_id} |awk -F ':' '{print $2}' | awk -F '"' '{print $2}')
  offset=$(awk '{print NR,$0}' tmp/${domain_id} |grep '"records"' | awk '{print $1}')

  awk "{if(NR>${offset})print \$0}" tmp/$domain_id |grep -E '"name"' |grep -v '@' |sort | uniq | awk -F ':' '{print $2}' | awk -F '"' '{print $2}' > tmp/$domain_name
  cat tmp/$domain_name | while read record ; do
	check_record=$record\.$domain_name
	echo $check_record
	CheckSSL
  done

done

if  [ ${Alert_Email} != "" ] ; then
    sendemail -o tls=yes -f "wanghuan@baixing.com" -t ${Alert_Email} -t wanghuan@baixing.com -s smtp.partner.outlook.cn:587 -xu wanghuan@baixing.com -xp 'wsad123!@#QWEASD' -u "${Alert_Days}天内证书过期域名清单" -o message-content-type=html -o message-charset=utf8 -m `cat  tmp/message.txt` >/dev/null 2>&1
fi

#########################################################
