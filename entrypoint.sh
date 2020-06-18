#!/bin/bash

# set -e

function upsertProperty() {
    local path="$1"
    local name="$2"
    local value="$3"

    local entry="$name</name>\n    <value>${value}</value>\n  </property>"
  
    echo "$name"
    if grep -q "$name" "$path"; then
        perl -0777 -pi -e "s|$name.*?</property>|$entry|sg;" "$path"
    else
        perl -0777 -pi -e "s|</configuration>|  <property>\n    <name>$entry\n\n</configuration>|sg;" "$path"
    fi
}

function configure() {
    local path="$1"
    local envPrefix="$2"

    local var
    local value
    
    for c in `printenv | perl -sne 'print "$1 " if m/^${envPrefix}_(.+?)=.*/' -- -envPrefix=$envPrefix`; do 
        name=`echo ${c} | perl -pe 's/___/-/g; s/__/_/g; s/_/./g'`
        var="${envPrefix}_${c}"
        value="${!var}"
        upsertProperty "$path" "$name" "$value"
    done
}


# Set sensitive config
config="$HADOOP_HOME/etc/hadoop"
echo "" > "$config/workers"

if [[ -z $HADOOP_SERVICES ]]; then
    export HADOOP_SERVICES="namenode resourcemanager historyserver datanode nodemanager"
fi
if [[ -z $XML_CORE_fs_defaultFS ]]; then
    export XML_CORE_fs_defaultFS="hdfs://localhost:9000"
fi

if [[ "$HADOOP_SERVICES" == *"namenode"* ]]; then
    export XML_HDFS_dfs_namenode_name_dir="$HADOOP_HOME/data/nameNode"
    mkdir -p "$HADOOP_HOME/data/nameNode"
fi
if [[ "$HADOOP_SERVICES" == *"datanode"* ]]; then
    export XML_HDFS_dfs_datanode_data_dir="$HADOOP_HOME/data/dataNode"
    mkdir -p "$HADOOP_HOME/data/dataNode"
fi
if [[ -z $CLUSTER_NAME ]]; then
    export CLUSTER_NAME="Hadoop"
fi


# Add env to conf
configure "$config/core-site.xml" XML_CORE
configure "$config/hdfs-site.xml" XML_HDFS
configure "$config/httpfs-site.xml" XML_HTTPFS
configure "$config/yarn-site.xml" XML_YARN
configure "$config/capacity-scheduler.xml" XML_CAPACITY_SCHEDULER
configure "$config/mapred-site.xml" XML_MAPRED
configure "$config/kms-site.xml" XML_KMS
configure "$config/kms-acls.xml" XML_KMS_ACLS
configure "$config/hadoop-policy.xml" XML_HADOOP_POLICY


# Start services
if [[ "$HADOOP_SERVICES" == *"namenode"* ]]; then
    if [[ ! -f "$config/flag" ]]; then
        hdfs namenode -format -force $CLUSTER_NAME
        touch $config/flag
    fi
    hdfs --daemon start namenode
fi
if [[ "$HADOOP_SERVICES" == *"resourcemanager"* ]]; then
    yarn --daemon start resourcemanager
fi
if [[ "$HADOOP_SERVICES" == *"historyserver"* ]]; then
    mapred --daemon start historyserver
fi

if [[ "$HADOOP_SERVICES" == *"datanode"* ]]; then
    hdfs --daemon start datanode
fi
if [[ "$HADOOP_SERVICES" == *"nodemanager"* ]]; then
    yarn --daemon start nodemanager
fi

tail -f /dev/null
