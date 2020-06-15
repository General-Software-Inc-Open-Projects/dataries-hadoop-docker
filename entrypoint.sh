#!/bin/bash

# set -e

config="$HADOOP_HOME/etc/hadoop"

echo "" > "$config/slaves"

# Create base conf file if missing
# if [[ ! -f "$config/zoo.cfg" ]]; then
#     cp "$config/zoo_sample.cfg" "$config/zoo.cfg"
# fi

export XML_HDFS_dfs_namenode_name_dir="$HADOOP_HOME/data/nameNode"
export XML_HDFS_dfs_datanode_data_dir="$HADOOP_HOME/data/dataNode"

function addProperty() {
  local path=$1
  local name=$2
  local value=$3

  local entry="<property><name>$name</name><value>${value}</value></property>"
  local escapedEntry=$(echo $entry | sed 's/\//\\\//g')
  sed -i "/<\/configuration>/ s/.*/${escapedEntry}\n&/" $path
}

function configure() {
    local path=$1
    local module=$2
    local envPrefix=$3

    local var
    local value
    
    echo "Configuring $module"
    for c in `printenv | perl -sne 'print "$1 " if m/^${envPrefix}_(.+?)=.*/' -- -envPrefix=$envPrefix`; do 
        name=`echo ${c} | perl -pe 's/___/-/g; s/__/_/g; s/_/./g'`
        var="${envPrefix}_${c}"
        value=${!var}
        echo " - Setting $name=$value"
        addProperty /etc/hadoop/$module-site.xml $name "$value"
    done
}

if [[ "$HADOOP_SERVICES" == *"namenode"* ]]; then
    hdfs namenode -format -force
    hadoop-daemon.sh --script hdfs start namenode
fi
if [[ "$HADOOP_SERVICES" == *"resourcemanager"* ]]; then
    yarn-daemon.sh start resourcemanager
fi
if [[ "$HADOOP_SERVICES" == *"proxyserver"* ]]; then
    yarn-daemon.sh start proxyserver
fi
if [[ "$HADOOP_SERVICES" == *"historyserver"* ]]; then
    mr-jobhistory-daemon.sh start historyserver
fi

if [[ "$HADOOP_SERVICES" == *"nodemanager"* ]]; then
    hadoop-daemon.sh --script hdfs start datanode
fi
if [[ "$HADOOP_SERVICES" == *"datanode"* ]]; then
    yarn-daemon.sh start nodemanager
fi

# exec "$@"

tail -f /dev/null
