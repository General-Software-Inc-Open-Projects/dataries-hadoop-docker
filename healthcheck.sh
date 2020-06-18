#!/bin/bash


if [[ "$HADOOP_SERVICES" == *"namenode"* ]]; then
    if [[ -z $HEALTHCHECK_URL_NAMENODE ]]; then
        export HEALTHCHECK_URL_NAMENODE="localhost:9870"
    fi
    if [[ $(curl -LI "$HEALTHCHECK_URL_NAMENODE/jmx" -s -o /dev/null -w "%{http_code}") -ne 200 ]]; then
        exit 1
    fi
fi
if [[ "$HADOOP_SERVICES" == *"resourcemanager"* ]]; then
    if [[ -z $HEALTHCHECK_URL_RESOURCEMANAGER ]]; then
        export HEALTHCHECK_URL_RESOURCEMANAGER="localhost:8088"
    fi
    if [[ $(curl -LI "$HEALTHCHECK_URL_RESOURCEMANAGER/jmx" -s -o /dev/null -w "%{http_code}") -ne 200 ]]; then
        exit 1
    fi
fi
if [[ "$HADOOP_SERVICES" == *"historyserver"* ]]; then
    if [[ -z $HEALTHCHECK_URL_HISTORYSERVER ]]; then
        export HEALTHCHECK_URL_HISTORYSERVER="localhost:19888"
    fi
    if [[ $(curl -LI "$HEALTHCHECK_URL_HISTORYSERVER/jmx" -s -o /dev/null -w "%{http_code}") -ne 200 ]]; then
        exit 1
    fi
fi

if [[ "$HADOOP_SERVICES" == *"nodemanager"* ]]; then
    if [[ -z $HEALTHCHECK_URL_NODEMANAGER ]]; then
        export HEALTHCHECK_URL_NODEMANAGER="localhost:8042"
    fi
    if [[ $(curl -LI "$HEALTHCHECK_URL_NODEMANAGER/jmx" -s -o /dev/null -w "%{http_code}") -ne 200 ]]; then
        exit 1
    fi
fi
if [[ "$HADOOP_SERVICES" == *"datanode"* ]]; then
    if [[ -z $HEALTHCHECK_URL_DATANODE ]]; then
        export HEALTHCHECK_URL_DATANODE="localhost:9864"
    fi
    if [[ $(curl -LI "$HEALTHCHECK_URL_DATANODE/jmx" -s -o /dev/null -w "%{http_code}") -ne 200 ]]; then
        exit 1
    fi
fi

exit 0