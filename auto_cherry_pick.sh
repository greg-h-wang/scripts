#!/bin/bash
#Author=dong

GITREPO=$1
GITENV=$2
COMMIT_ID=$3
RT_VERSION=$4
MERGER_ID=$5
SSSSS=$6


# base the system time to judge now version,because every weekday to  add 1  like  NOWNUM=NOWNUM+
# 1.11

NOWNUM=$(echo 198+`date +%W` |bc)

case $GITREPO   in
data-ego)
      GITPMA=dte/data-ego
       ;;
data-ego-console)
      GITPMA=dte/data-ego-console
       ;;
asset-router)
      GITPMA=loan/asset-router
       ;;
ifc)
      GITPMA=never/ifc
       ;;
rc-frontend)
      GITPMA=rc/rc-frontend
       ;;
athena)
      GITPMA=never/athena
       ;;
mca_h5)
      GITPMA=trade/mca_h5
       ;;
cast-backend)
      GITPMA=cas/cast-backend
       ;;
cast-frontend)
      GITPMA=trade/red-frontend
       ;;
neverdies)
      GITPMA=never/neverdies
       ;;
loan-app)
     GITPMA=loan/loan-app
       ;;
loan-product-center)
     GITPMA=loan/loan-product-center
       ;;
loan-common)
    GITPMA=loan/loan-common
    ;;
red-frontend)
     GITPMA=trade/red-frontend
      ;;
crm)
    GITPMA=crm/crm
      ;;
acrc)
    GITPMA=rc/acrc
      ;;
rc-rbms)
    GITPMA=rc/rc-rbms
      ;;
workflow)
   GITPMA=wf/workflow
      ;;
promotion)
   GITPMA=prom/promotion
     ;;
adminconsole)
   GITPMA=opc/adminconsole
     ;;
crc)
  GITPMA=crc/crc
      ;;
cmc)
   GITPMA=cmc/cmc
     ;;
sns-api)
   GITPMA=napi/sns-api
    ;;
frontend-main)
   GITPMA=fe/frontend-main
      ;;
mainapp)
  GITPMA=main/mainapp
    ;;
casterly)
 GITPMA=loan/casterly
   ;;
plateaux)
   GITPMA=ever/plateaux
       ;;
bonuspoint)
 GITPMA=bonp/bonuspoint
   ;;
auth-server)
 GITPMA=uniaz/auth-server
    ;; 
eyrie)
 GITPMA=ever/eyrie
   ;;
social-store-backend)
  GITPMA=sos/social-store-backend
   ;;
social-store-front)
  GITPMA=sos/social-store-front
     ;;
borrower-app)
   GITPMA=bapp/borrower-app
    ;;
themis)
   GITPMA=loan/themis
    ;;
lb-ams)
   GITPMA=ams/lb-ams
   ;;
frontend-borrower)
    GITPMA=fe/frontend-borrower
    ;;
frontend-cms)
    GITPMA=cms/frontend-cms
	;;
cis-server-cms)
    GITPMA=ras/cis-server-cms
	;;
frontend-api)
    GITPMA=napi/frontend-api
	;;
braavos)
    GITPMA=braav/braavos
	;;
frontend-sales)
   GITPMA=sp/frontend-sales
     ;;
sales-platform-backend)
   GITPMA=sp/sales-platform-backend
     ;;
maketsolution)
    GITPMA=mkts/maketsolution
	 ;;
uniauth)
    GITPMA=uniaz/uniauth
	 ;;
xcrm)
   GITPMA=xhcrm/xcrm
    ;;
cash)
   GITPMA=cl/cash
    ;;
ethereum-app)
   GITPMA=bloc/ethereum-app
    ;;
riverrun)
   GITPMA=river/riverrun
    ;;
winterfell)
  GITPMA=main/winterfell
      ;;
motivationcruiser)
   GITPMA=mtc/motivationcruiser
      ;;
foundationservice)
   GITPMA=mtc/foundationservice
      ;;
frontend-dx)
   GITPMA=sp/frontend-dx
      ;;
social-forum-backend)
  GITPMA=sof/social-forum-backend
		      ;;
social-forum-java)
  GITPMA=sof/social-forum-java
	;;
borrower-job)
  GITPMA=loan/borrower-job
       ;;
envoy)
   GITPMA=sp/envoy
     ;;
crm-frontend)
   GITPMA=crm/crm-frontend
    ;;
bdchannel)
    GITPMA=ams/bdchannel
	    ;;
staticcruiser)
   GITPMA=mtc/staticcruiser
      ;;
marketstatic)
    GITPMA=mkts/marketstatic
   ;;
drshop)
   GITPMA=drshop/drshop
     ;;
trust)
   GITPMA=never/trust
     ;;
notification)
   GITPMA=notif/notification
       ;;
ams-external-service)
   GITPMA=ams/ams-external-service
      ;;
starwinoperating)
    GITPMA=mkts/starwinoperating
   ;;
starwinstatic)
    GITPMA=mkts/starwinstatic
    ;;
cmc-job)
    GITPMA=main/cmc-job
    ;;
drvip)
   GITPMA=bonp/drvip
       ;;
drvip-frontend)
  GITPMA=bonp/drvip-frontend
      ;;
smart-collection-be)
  GITPMA=scl/smart-collection-be
     ;;
ms-backend)
    GITPMA=ftsp/ms-backend
	      ;;
iron-bank)
    GITPMA=braav/iron-bank
	      ;;
people)
   GITPMA=dp/people
     ;; 
bpo-backend)
   GITPMA=bpo/bpo-backend
     ;;
mobile-lender-android)
    GITPMA=lapp/mobile-lender-android
        ;;
data-aggregation)
    GITPMA=ever/data-aggregation
      ;;
borrow-api)
   GITPMA=loan/borrow-api
   ;;
eeloan_frontend)
    GITPMA=eel/eeloan_frontend
    ;;
investment-api)
   GITPMA=main/investment-api
    ;;
bpo-loanriver)
   GITPMA=bpo/bpo-loanriver
     ;;
eeloan_backend)
   GITPMA=eel/eeloan_backend
     ;;
gloan_backend)
   GITPMA=gloan/gloan_backend
    ;;
borrowing-job)
   GITPMA=main/borrowing-job
     ;;
borrow-channel)
   GITPMA=loan/borrow-channel
     ;;
neverland)
   GITPMA=never/neverland
      ;;
opchannel_html)
    GITPMA=mc/opchannel_html
      ;;
leads-exchange)
     GITPMA=main/leads-exchange
       ;;
borrower-lite) 
    GITPMA=sp/borrower-lite
   ;;
icrc)
   GITPMA=icrc/icrc
   ;;
quota)
   GITPMA=quota/quota
   ;;
insurance_gateway)
   GITPMA=isc/insurance_gateway
   ;;
third_party_api)
   GITPMA=isc/third_party_api
   ;;
abt-console)
   GITPMA=dp/abt-console
   ;;
abt-service)
   GITPMA=dp/abt-service
   ;;
data-ego-console)
   GITPMA=dte/data-ego-console
   ;;
data-ego)
   GITPMA=dte/data-ego
   ;;
social-fourm-front)
   GITPMA=sof/social-fourm-front
   ;;
*)
      echo "can't find this repo"
esac


GIT_URL=ssh://dongy@code.dianrong.com:7999/

oldIFS=$IFS
IFS=,

echo "$GIT_URL $GITPMA"
WSPACE=$RANDOM
cd $(dirname $0)
mkdir -pv auto_merge/$WSPACE  && cd  auto_merge/$WSPACE

cherry_demo_stage ()  {
for  COMMIT in $COMMIT_ID
do
  rm -rf $GITREPO  && git clone $GIT_URL$GITPMA
  ret_clone=`echo $?`
  if [ $ret_clone != 0 ]
  then
   echo "git clone is failed"
   break
  fi

  cd $GITREPO  && git checkout $NOWBRANCH
  ret_checkout=`echo $?`

  if [ $ret_checkout != 0 ]
  then
   echo "$NOWBRANCH is not exist"
   cd ..
   break
  fi

  git cherry-pick $COMMIT
  ret1=`echo $?`
  if [ $ret1 != 0 ]
  then
      if  [ $ret1 == 1 ]  &&  git cherry-pick $COMMIT | grep  nothing ;
      then
          ret1=0
      else
          echo "ret1 is : $ret1"
          echo "current commit id is: $COMMIT"
          break
      fi
  else
      git push origin $NOWBRANCH
      ret_push=`echo $?`

      if [ $ret_push != 0 ]
      then 
	  echo $ret_push
          echo "git push is wrong"
          ret1=3
          cd ..
          break
      fi

  fi
  cd ..
done

if [ $ret_clone != 0 ]
then
    return_code=3
else
    if [ $ret1 == 0 ]
    then
       echo "merge successully"
       return_code=0
    elif [ $ret1 == 1 ]
    then
       echo "merge conflict"
       return_code=1
    elif [ $ret1 == 128 ]
    then
       echo "bad revision;wrong  commit_id"
       return_code=4
    else
       echo "other unknown errors"
       return_code=2
    fi
fi

if [ $return_code != 0 ]
then
    echo "cherry-pick $NOWBRANCH  is failed"
fi

}


cherry_prod  ()  {


rm -rf $GITREPO  && git clone $GIT_URL$GITPMA
cd $GITREPO


FIRSTNUM=`git branch -a | grep release/rt$RT_VERSION | tail -n 1 | awk -F '/rt' '{print $NF}'`
TOBRANCH=release/rt$(echo "$FIRSTNUM+0.01" |bc)


for  COMMIT in $COMMIT_ID
do
  cd $(dirname $0)
  rm -rf $GITREPO  && git clone $GIT_URL$GITPMA
  ret_clone=`echo $?`
  if [ $ret_clone != 0 ]
  then
   echo "git clone is failed"
   break
  fi
  cd $GITREPO
  HOTFIXNUM=`git branch -a | grep release/rt$RT_VERSION | tail -n 1 | awk -F '/rt' '{print $NF}'`
  FROMBRANCH=release/rt$HOTFIXNUM   
  git checkout $FROMBRANCH
  git checkout -b $TOBRANCH && echo "cut $TOBRANCH from $FROMBRANCH" || echo "$TOBRANCH is exist"
  git cherry-pick $COMMIT
  ret1=`echo $?`
  if [ $ret1 != 0 ]
  then
      if  [ $ret1 == 1 ]  &&  git cherry-pick $COMMIT | grep  nothing ;
      then
          ret1=0
      else
          echo "ret1 is : $ret1"
          echo "current commit id is: $COMMIT"
          break
      fi
  else
      git push origin $TOBRANCH
	  ret_push=`echo $?`

	  if [ $ret_push != 0 ]
	  then
	      echo $ret_push
	      echo "git push is wrong"
              ret1=3
	      cd ..
	      break
      fi
  fi
  cd ..
done
rm -rf $GITREPO


if [ $ret_clone != 0 ]
then
    return_code=3
else
    if [ $ret1 == 0 ]
    then
       echo "merge successully"
       return_code=0
    elif [ $ret1 == 1 ]
    then
       echo "merge conflict"
       return_code=1
    elif [ $ret1 == 128 ]
    then
       echo "bad revision;wrong  commit_id"
       return_code=4
    else
       echo "other unknown errors"
       return_code=2
    fi
fi

if [ $return_code != 0 ]
then
    echo "cherry-pick $TOBRANCH  is failed"
fi
}




case $GITENV in
demo)
     NOWBRANCH=release/rt$NOWNUM
     cherry_demo_stage
     minor_rt_version=RT$NOWNUM
      ;;

stage)
     NOWBRANCH=release/rt$RT_VERSION
     cherry_demo_stage
     minor_rt_version=RT$RT_VERSION

     if [ $return_code != 0 ]
     then
         echo "cherry-pick  RT$RT_VERSION  is failed"
     else
         NOWBRANCH=release/rt$(($RT_VERSION+1))
         cherry_demo_stage
     fi

	  ;;

prod)
    cherry_prod
    minor_rt_version=RT$(echo "$FIRSTNUM+0.01" |bc)

    if [ $return_code != 0 ]
    then
         echo "cherry-pick $minor_rt_version is failed"
    else
         NOWBRANCH=release/rt$(($RT_VERSION+1))
         cherry_demo_stage

         if [ $return_code != 0 ]
         then
             echo "cherry-pick rt$(($RT_VERSION+1))  is failed"
         else
             NOWBRANCH=release/rt$(($RT_VERSION+2))
             cherry_demo_stage
         fi
    rm $WSPACE  -rf
    fi
    ;;
esac

