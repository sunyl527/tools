#!/bin/sh
set -e
Conf_Dir=/opt/adapter/conf
# 配置adapter中的canal-server的模式
if [ ${Canal_mode} == 'kafka' ]; then
  sed -i "/^.*mode:/ s/:.*/: ${Canal_mode}/" ${Conf_Dir}/application.yml
  sed -i  "/mqServers:/ s/:.*/: ${Mq_Servers}/" ${Conf_Dir}/application.yml
elif [ ${Canal_mode} == 'tcp' ]; then
  sed -i "/^.*mode:/ s/:.*/: ${Canal_mode}/" ${Conf_Dir}/application.yml
  sed -i  "/mqServers:/ s/mqServers:.*/canalServerHost: ${Canal_Servers}/" ${Conf_Dir}/application.yml
else
  echo "Invalid mode ${Canal_mode}, This image support tcp and kafka mode now"
  exit 1
fi

# 源mysql地址
if [ -n ${Src_Data_Server} ]; then
  sed -i  "/^.*url: jdbc:mysql:/ s/mysql:.*/mysql:\/\/${Src_Data_Server}\/${Src_Database}?useUnicode=true/" ${Conf_Dir}/application.yml
fi

# 源mysql用户名
if [ -n ${Src_User} ]; then
  sed -i  "/^.*username:/ s/:.*/: ${Src_User}/" ${Conf_Dir}/application.yml
fi

# 源mysql用户名密码
if [ -n ${Src_Password} ]; then
  sed -i  "/^.*password:/ s/:.*/: ${Src_Password}/" ${Conf_Dir}/application.yml
fi

# 配置实例名称，若为tcp模式，则与canal-server中实例名称一直，若为tcp模式，则与topic名称一直
if [ -n ${Adapter_instance} ]; then
  sed -i  "/- instance:/ s/:.*/: ${Adapter_instance}/g" ${Conf_Dir}/application.yml
  sed -i "/destination:/ s/:.*/: ${Adapter_instance}/g" ${Conf_Dir}/rdb/mytest_user.yml
  sed -i "/destination:/ s/:.*/: ${Adapter_instance}/g" ${Conf_Dir}/es/mytest_user.yml
fi

for Out in ${Out_adapters}
do
  echo ${Out}
  if [ ${Out} == 'rdb' ];then
    if [ -n ${Src_Database} ]; then
      sed -i  "/^.*database:/ s/:.*/: ${Src_Database}/" ${Conf_Dir}/rdb/mytest_user.yml
    fi
    if [ -n ${Src_Table} ]; then
      sed -i  "/^.*table:/ s/:.*/: ${Src_Table}/" ${Conf_Dir}/rdb/mytest_user.yml
    fi

    if [ -n ${Dest_User} ]; then
      sed -i  "/^.*jdbc.username:/ s/:.*/: ${Dest_User}/" ${Conf_Dir}/application.yml
    fi
    if [ -n ${Dest_Password} ]; then
      sed -i  "/^.*jdbc.password:/ s/:.*/: ${Dest_Password}/" ${Conf_Dir}/application.yml
    fi
    if [ -n ${Dest_Database} ] && [ -n ${Dest_Table} ]; then
      sed -i  "/^.*targetTable:/ s/:.*/: ${Dest_Database}.${Dest_Table}/" ${Conf_Dir}/rdb/mytest_user.yml
    fi
    if [ -n ${Target_Pk} ]; then
      R_Target_Pk=`echo $Target_Pk | sed -e 's/:/: /g'`
      sed -i  "/^.*targetPk:/{n;s/[a-z].*/${R_Target_Pk}/g}" ${Conf_Dir}/rdb/mytest_user.yml
    fi
    if [ -n ${Dest_Data_Server} ]; then
      sed -i  "/^.*jdbc.url: jdbc:mysql:/ s/mysql:.*/mysql:\/\/${Dest_Data_Server}\/${Dest_Database}/" ${Conf_Dir}/application.yml
    fi
    if [ ${Map_All} == 'true' ]; then
      sed -i "/mapAll:/c\  mapAll: true" ${Conf_Dir}/rdb/mytest_user.yml
      sed -i "/targetColumns:/c\#  targetColumns:" ${Conf_Dir}/rdb/mytest_user.yml
    else
      sed -i "/mapAll:/c\#  mapAll: true" ${Conf_Dir}/rdb/mytest_user.yml
      sed -i "/targetColumns:/c\  targetColumns:" ${Conf_Dir}/rdb/mytest_user.yml
      for colume in ${Mapping_Columes}
      do
        R_colume=`echo $colume | sed -e 's/:/: /g'`
        sed -i "/^.*targetColumns:/a\    ${R_colume}" ${Conf_Dir}/rdb/mytest_user.yml
      done
    fi
  elif [ ${Out} == 'es' ];then
    if [ -n ${Es_hosts} ];then
      sed -i "/^.*hosts:/ s/hosts:.*/hosts: ${Es_hosts}/" ${Conf_Dir}/application.yml
    fi
    if [ -n ${Es_cluster} ];then
      sed -i "/^.*cluster.name:/ s/name:.*/name: ${Es_cluster}/" ${Conf_Dir}/application.yml
    fi
    if [ -n ${Es_index} ];then
      sed -i "/^.*_index:/ s/index:.*/index: ${Es_index}/"  ${Conf_Dir}/es/mytest_user.yml
    fi
    if [ -n ${Es_type} ];then
      sed -i "/^.*_type:/ s/type:.*/type: ${Es_type}/"  ${Conf_Dir}/es/mytest_user.yml
    fi
    if [ -n ${Es_id} ];then
      sed -i "/^.*_id:/ s/id:.*/id: ${Es_id}/"  ${Conf_Dir}/es/mytest_user.yml
    fi
    sed -i "/^.*sql:/ s/sql:.*/sql: ${Sql_map}/"  ${Conf_Dir}/es/mytest_user.yml
  else
    echo "Invalid outerAdapters ${Out}, This image support es and rdb mode now"
    exit 1
  fi
done

sh /opt/adapter/bin/startup.sh
tail -F /opt/adapter/logs/adapter/adapter.log