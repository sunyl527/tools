cat > /home/canal/conf/canal.properties <<- EOF
# register ip
# ${HOSTNAME} 为podname，canal-server-discovery-svc-stable为svc名称
# StatefulSet类型pod名称是固定的，k8s集群内pod域名规则为pod_name.svc_name.namespace.svc.cluster.local
canal.register.ip = ${HOSTNAME}

# canal admin config
canal.admin.manager = canal-admin:8089
canal.admin.port = 11110
canal.admin.user = admin
canal.admin.passwd = 4ACFE3202A5FF5CF467898FC58AAB1D615029441
# admin auto register
canal.admin.register.auto = true
canal.admin.register.cluster =
EOF
sh /home/canal/bin/restart.sh