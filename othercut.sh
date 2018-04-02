#!/bin/bash
#Author=dong

GIT_RELEASE=$(echo 200+`date +%U` |bc)

_GITLIST="napi/sns-api
napi/shorturl"

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



fun_1
