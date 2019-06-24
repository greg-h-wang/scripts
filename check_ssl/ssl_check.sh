#!/bin/bash

CheckDomains="example.com abc.com"
Alert_Email=""
Alert_Days="10"
Cur_Dir=$(dirname $0)

Check()
{
    Cur_Time=$(date +%s)
    Expire_Date=$(curl -o /dev/null -m 10 --connect-timeout 10 -svIL https://${Domain} 2>&1|grep "expire date:"|sed 's/*\s\+expire date:\s\+//')
    Expire_Time=$(date -d "${Expire_Date}" +%s)
    Alert_Time=$((${Expire_Time}-${Alert_Days}*86400))
    Expire_Date_Read=$(date -d @${Expire_Time} "+%Y-%m-%d")

    echo "Domain:${Domain} Expire Date: ${Expire_Date_Read}"

    if [ ${Cur_Time} -ge ${Alert_Time} ] &&  [ ${Alert_Email} != "" ] ; then
        python ${Cur_Dir}/sendmail.py "${Alert_Email}" "Domain: ${Domain} SSL Certificate Expire Notice" "Domain: ${Domain} SSL Certificate will expire on ${Expire_Date_Read}."
    fi

    sleep 2
}

for Domain in ${CheckDomains[@]};do
    Check ${Domain}
done
