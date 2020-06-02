#!/bin/bash

echo "" > $HADOOP_HOME/etc/hadoop/slaves

sed -i "s|SCHEDULER_MAX_AM_PERCENT|$SCHEDULER_MAX_AM_PERCENT|" "$HADOOP_HOME/etc/hadoop/capacity-scheduler.xml"

sed -i "s|DEFAULT_FS|$DEFAULT_FS|" "$HADOOP_HOME/etc/hadoop/core-site.xml"
sed -i "s|HTTP_USER|$HTTP_USER|" "$HADOOP_HOME/etc/hadoop/core-site.xml"

sed -i "s|NAMENODE_PATH|$HADOOP_HOME/data/nameNode|" "$HADOOP_HOME/etc/hadoop/hdfs-site.xml"
sed -i "s|DATANODE_PATH|$HADOOP_HOME/data/dataNode|" "$HADOOP_HOME/etc/hadoop/hdfs-site.xml"
sed -i "s|REPLICATION_FACTOR|$REPLICATION_FACTOR|" "$HADOOP_HOME/etc/hadoop/hdfs-site.xml"

sed -i "s|RM_HOSTNAME|$RM_HOSTNAME|" "$HADOOP_HOME/etc/hadoop/yarn-site.xml"
sed -i "s|NODEMANAGER_MB|$NODEMANAGER_MB|" "$HADOOP_HOME/etc/hadoop/yarn-site.xml"
sed -i "s|SCHEDULER_MAX_MB|$SCHEDULER_MAX_MB|" "$HADOOP_HOME/etc/hadoop/yarn-site.xml"
sed -i "s|SCHEDULER_MIN_MB|$SCHEDULER_MIN_MB|" "$HADOOP_HOME/etc/hadoop/yarn-site.xml"
sed -i "s|SCHEDULER_INC_MB|$SCHEDULER_INC_MB|" "$HADOOP_HOME/etc/hadoop/yarn-site.xml"
sed -i "s|LOG_AGGREGATION|$LOG_AGGREGATION|" "$HADOOP_HOME/etc/hadoop/yarn-site.xml"

if [[ $HADOOP_ROLE = "master" ]]; then
    $HADOOP_HOME/bin/hdfs namenode -format -force
    $HADOOP_HOME/sbin/hadoop-daemon.sh --script hdfs start namenode
    $HADOOP_HOME/sbin/yarn-daemon.sh start resourcemanager
    $HADOOP_HOME/sbin/yarn-daemon.sh start proxyserver
    $HADOOP_HOME/sbin/mr-jobhistory-daemon.sh start historyserver

    while [[ $( jps | grep -e 'NameNode' -e 'ResourceManager' -e 'JobHistoryServer' | wc -l ) -eq 3 ]]; do
        sleep 5
    done

    exit 1
else    
    $HADOOP_HOME/sbin/hadoop-daemon.sh --script hdfs start datanode
    $HADOOP_HOME/sbin/yarn-daemon.sh start nodemanager

    while [[ $( jps | grep -e 'DataNode' -e 'NodeManager' | wc -l ) -eq 2 ]]; do
        sleep 5
    done

    exit 1
fi
