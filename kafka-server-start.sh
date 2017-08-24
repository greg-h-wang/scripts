#! /bin/bash

if [ ! -d /app_logs/${AppID}]; 
then
	mkdir /app_logs/${AppID}
fi

HOSTNAME=`hostname`
IP=`ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v 172 |grep -v inet6|awk '{print $2}'|tr -d "addr:"`
echo ${IP} ${HOSTNAME} >> /etc/hosts

for VAR in `env`
do
  if [[ $VAR =~ ^KAFKA_ && ! $VAR =~ ^KAFKA_HOME ]]; 
  then
    kafka_name=`echo "$VAR" | sed -r "s/KAFKA_(.*)=.*/\1/g" | tr '[:upper:]' '[:lower:]' | tr _ .`
    env_var=`echo "$VAR" | sed -r "s/(.*)=.*/\1/g"`
	env_var_value=`echo "$VAR" | awk -F '=' '{print $NF}'`
    if egrep -q "(^|^#)$kafka_name=" $KAFKA_HOME/config/server.properties;
    then
        sed -r -i "s@(^|^#)($kafka_name)=(.*)@\2=${env_var_value}@g" $KAFKA_HOME/config/server.properties 
    else
	echo $kafka_name=${env_var_value} >> $KAFKA_HOME/config/server.properties
    fi
  fi
done

if [ $# -lt 1 ];
then
	echo "USAGE: $0 [-daemon] server.properties [--override property=value]*"
	exit 1
fi
base_dir=$(dirname $0)

if [ "x$KAFKA_LOG4J_OPTS" = "x" ]; then
    export KAFKA_LOG4J_OPTS="-Dlog4j.configuration=file:$base_dir/../config/log4j.properties"
fi

if [ "x$KAFKA_HEAP_OPTS" = "x" ]; then
    export KAFKA_HEAP_OPTS="-Xmx1G -Xms1G"
fi

EXTRA_ARGS=${EXTRA_ARGS-'-name kafkaServer -loggc'}

COMMAND=$1
case $COMMAND in
  -daemon)
    EXTRA_ARGS="-daemon "$EXTRA_ARGS
    shift
    ;;
  *)
    ;;
esac

exec $base_dir/kafka-run-class.sh $EXTRA_ARGS kafka.Kafka "$@"
