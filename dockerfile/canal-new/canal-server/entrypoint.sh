#!/bin/bash

Base_dir=/opt/canal-server/conf
Log_dir=/opt/canal-server/logs

set -e
# 配置canal-server的运行模式，当前镜像支持tcp和kafka
if [ -n "${canal_serverMode}" ]; then
  sed -i "/^canal.serverMode/ s/serverMode.*/serverMode = ${canal_serverMode}/" ${Base_dir}/canal.properties
else
  echo "Invalid mode ${canal_serverMode}, This image support tcp and kafka mode now"
  exit 1
fi

if [ -n "${instances}" ]; then
  destinations=$(echo ${instances} | sed 's/ /,/g')
  sed -i "/^canal.destinations/ccanal.destinations = ${destinations}" ${Base_dir}/canal.properties
  for instance in ${instances}
  do
    declare -A dict
    ins_dic=$(eval echo '$'"{${instance}_dict}" | awk -F'"' '{print $2}')
    for kv in ${ins_dic}
    do
      k=`echo $kv | awk -F'=' '{print $1}'`
      v=`echo $kv | awk -F'=' '{print $2}'`
      dict[$k]=$v
    done
    if [ "${instance}" != "example" ]; then
      mkdir ${Base_dir}/${instance} && cp ${Base_dir}/example/* ${Base_dir}/${instance}/
      if [ ${canal_serverMode} = 'kafka' ]; then
        sed -i "/^canal.mq.servers/ccanal.mq.servers=${canal_mq_servers}" ${Base_dir}/canal.properties
        if [ -n "${dict[canal_mq_topic]}" ];then
          sed -i "/.*canal.mq.topic/ccanal.mq.topic=${dict[canal_mq_topic]}" ${Base_dir}/${instance}/instance.properties
        else
          sed -i "/^canal.mq.topic/d" ${Base_dir}/${instance}/instance.properties
          sed -i "/.*canal.mq.dynamicTopic=/ccanal.mq.dynamicTopic=${dict[canal_mq_dynamicTopic]}" ${Base_dir}/${instance}/instance.properties
        fi
      fi

      if [ -n "${dict[canal_instance_master_address]}" ]; then
        sed -i  "/^canal.instance.master.address=/ccanal.instance.master.address=${dict[canal_instance_master_address]}" ${Base_dir}/${instance}/instance.properties
      fi

      if [ -n "${dict[canal_instance_filter_regex]}" ]; then
        sed -i "/^canal.instance.filter.regex/ccanal.instance.filter.regex=${dict[canal_instance_filter_regex]}" ${Base_dir}/${instance}/instance.properties
      fi
    fi
  done
fi

/bin/sh /opt/canal-server/bin/startup.sh
sleep 3
tail -F /opt/canal-server/logs/canal/canal.log