#!/bin/bash


if [[ $HADOOP_ROLE = "master" ]]; then

    yarn_result=$(curl -I http://$(hostname):8088 -s -o /dev/null -w "%{http_code}")
    hdfs_result=$(curl -I http://$(hostname):50070 -s -o /dev/null -w "%{http_code}")

    if [[ $yarn_result -eq 302 && $hdfs_result -eq 200 ]]; then
        exit 0
    else
        exit 1
    fi

else
    
    yarn_result=$(curl -I http://$(hostname):8042 -s -o /dev/null -w "%{http_code}")
    hdfs_result=$(curl -I http://$(hostname):50075 -s -o /dev/null -w "%{http_code}")
    
    if [[ $yarn_result -eq 302 && $hdfs_result -eq 200 ]]; then
        exit 0
    else
        exit 1
    fi

fi
