#!/bin/bash
#Author=dong

GIT_RELEASE=$(echo 200+`date +%U` |bc)

_GITLIST="crm/crm
loan/cash-loan
crm/crm-frontend
never/neverdies
uniaz/auth-server
uniaz/old_uniauth
sp/sales-platform-backend
loan/acrc
main/mainapp
main/winterfell
bonp/bonuspoint
loan/themis
ams/bdchannel
loan/loan-app
loan/loan-common
loan/borrower-job
wf/workflow
opc/adminconsole
sp/envoy
crc/crc
op/openapplication
xhcrm/xcrm
mtc/motivationcruiser
prom/promotion
xprom/xpromotion
never/athena
notif/notification
ever/silverstag
ever/eyrie
ever/plateaux
sp/frontend-sales
river/riverrun
#bapp/borrower-app
fe/frontend-main
fe/frontend-borrower
cms/frontend-cms
napi/frontend-api
mkts/maketsolution
drshop/drshop
bonp/drvip
bonp/drvip-frontend
mkts/marketstatic
mtc/staticcruiser
ams/ams-external-service
scl/smart-collection-be
mkts/starwinoperating
mkts/starwinstatic
loan/contract_center
bpo/bpo-backend
main/investment-api
dp/people
dp/people-static
main/borrow-api
braav/iron-bank
loan/quota
ever/data-aggregation
main/investment-api
plat/service-governance
loan/loan-shelf
bpo/bpo-loanriver
quota/quota
main/borrowing-job
loan/borrow-channel
sp/borrower-lite
main/cmc-job
quota/quota-portal
never/neverland
eel/eeloan_backend
loan/loan-product-center
icrc/icrc
napi/sns-api
ras/cis-server-shorturl
ras/cis-server-cms
uniaz/uniauth"

GIT_URL=ssh://dongy@code.dianrong.com:7999/

TIME_START=`date +%F-%H`

mkdir /opt/users/dong/423/cutjob/repo/cutbranch-$TIME_START
fun_1  ()  {
for GITPM in  $_GITLIST
do
   cd /opt/users/dong/423/cutjob/repo/cutbranch-$TIME_START
   git clone $GIT_URL$GITPM
   GIT_REPO=`echo $GITPM  | cut -d / -f2`
   cd $GIT_REPO
   git checkout -b release/rt$GIT_RELEASE
   git branch  >> ../a
   git push origin release/rt$GIT_RELEASE
   echo  "$GIT_REPO  cut  rt$GIT_RELEASE  is okay" >> ../a
done
}

fun_2  () {
#mail to dba
cd  /opt/users/dong/423/cutjob/repo/cutbranch-$TIME_START
find . -name *${GIT_RELEASE}*.sql >  ${GIT_RELEASE}
sed -i 's#./##'   ${GIT_RELEASE}
cat a  | egrep -v ${GIT_RELEASE}  | egrep -v develop | egrep -v master | egrep -v ship  >  ss
echo | mutt -s "all sql match ${GIT_RELEASE} from rt${GIT_RELEASE}" -i ${GIT_RELEASE} dba@dianrong.com
echo | mutt -s "all sql match ${GIT_RELEASE} from rt${GIT_RELEASE}" -i ${GIT_RELEASE} yahui.dong@dianrong.com
echo | mutt -s "cut branch rt${GIT_RELEASE} done" -i a   yahui.dong@dianrong.com
echo | mutt -s "undo cut branch rt${GIT_RELEASE} done" -i ss   yahui.dong@dianrong.com
}


#replace demo revision
fun_3 () {
find /opt/jenkins/home/jobs/DianRong/jobs/Demo/jobs -name config.xml   -exec sed -i "s#release/rt[0-9]*#release/rt$GIT_RELEASE#" '{}' ';'
docker restart JENKINS
}



fun_1
fun_2
fun_3
