# Description

This image was created with the intention of quickly deploy and configure Apache Hadoop component on Docker. We are not associated with Apache or Hadoop in anyway.

# Quick reference

- Maintained by: [General Software Inc Open Projects](https://github.com/General-Software-Inc-Open-Projects/hadoop-docker)
- Where to file issues: [GitHub Issues](https://github.com/General-Software-Inc-Open-Projects/hadoop-docker/issues)

# What is Apache Hadoop?

The [Apache Hadoop](https://hadoop.apache.org/) software library is a framework that allows for the distributed processing of large data sets across clusters of computers using simple programming models. It is designed to scale up from single servers to thousands of machines, each offering local computation and storage. Rather than rely on hardware to deliver high-availability, the library itself is designed to detect and handle failures at the application layer, so delivering a highly-available service on top of a cluster of computers, each of which may be prone to failures.

# How to use this image

## Start a single node Hadoop server

~~~bash
docker run -itd --name hadoop -e "XML_CORE_hadoop_http_staticuser_user=hadoop" -e "XML_HDFS_dfs_replication=1" -p 9870:9870 -p 8088:8088 -p 19888:19888 -p 8042:8042 -p 9864:9864 --restart on-failure gsiopen/hadoop:3.2.1
~~~

## Persist data

> This image is runned using a non root user `hadoop` who owns the `/opt/hadoop` folder.

By default, hadoop's data is stored in `/opt/hadoop/data`. You can bind local volume as follows:

~~~bash
docker run -itd --name hadoop -v /path/to/store/data:/opt/hadoop/data -e "XML_CORE_hadoop_http_staticuser_user=hadoop" -e "XML_HDFS_dfs_replication=1" -p 9870:9870 -p 8088:8088 -p 19888:19888 -p 8042:8042 -p 9864:9864 --restart on-failure gsiopen/hadoop:3.2.1
~~~

## Connect to Hadoop from the command line client

All `CLI` scripts are contained in `PATH`, so you can invoke them using their respective commands and arguments as follows: 

~~~bash
docker exec -it hadoop hadoop fs -ls /
~~~

## Logging

You can find out if something went wrong while initializing the container using the next command:

~~~bash
docker logs hadoop
~~~

The rest can be found in the `logs` folder with format `hadoop-hadoop-[service]-[hostname].[log|out]`

# Deploy a cluster

Hadoop is conformed by many services, to select which ones will be launched in each container, use the next environment variable:

### `HADOOP_SERVICES`

> Hadoop services that will be started as daemons in the container, options are: `namenode`, `resourcemanager`, `historyserver`, `nodemanager`, `datanode`.

You have to configure each container accordingly to the services you intent to launch on them, check the official documentation [here](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/ClusterSetup.html) to learn how it is done. 

Example using `docker-compose`:

~~~yaml
version: "3.7"

networks:
  private-net:
    name: private-net
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 192.168.1.0/24

services:
  hadoop-master:
    image: gsiopen/hadoop:3.2.1
    container_name: hadoop-master
    hostname: hadoop-master
    environment:
      - HADOOP_SERVICES="namenode resourcemanager historyserver"
      - XML_CORE_fs_defaultFS=hdfs://hadoop-master:9000
      - XML_CORE_hadoop_http_staticuser_user=hadoop
      - XML_HDFS_dfs_replication=2
      - XML_YARN_yarn_log___aggregation___enable=true
    restart: on-failure
    networks:
      private-net:
        ipv4_address: 192.168.1.2

  hadoop-slave-1:
    image: gsiopen/hadoop:3.2.1
    container_name: hadoop-slave-1
    hostname: hadoop-slave-1
    environment:
      - HADOOP_SERVICES="nodemanager datanode"
      - XML_CORE_fs_defaultFS=hdfs://hadoop-master:9000
      - XML_YARN_yarn_resourcemanager_hostname=hadoop-master
    depends_on:
      - hadoop-master
    restart: on-failure
    networks:
      private-net:
        ipv4_address: 192.168.1.3

  hadoop-slave-2:
    image: gsiopen/hadoop:3.2.1
    container_name: hadoop-slave-2
    hostname: hadoop-slave-2
    environment:
      - HADOOP_SERVICES="nodemanager datanode"
      - XML_CORE_fs_defaultFS=hdfs://hadoop-master:9000
      - XML_YARN_yarn_resourcemanager_hostname=hadoop-master
    depends_on:
      - hadoop-master
    restart: on-failure
    networks:
      private-net:
        ipv4_address: 192.168.1.4
~~~

# Configuration

## Volumes

Hadoop uses configuration files in the `/opt/hadoop/etc/hadoop` folder. You can bind an external folder with your configuration files as follows:

~~~bash
docker run -itd --name hadoop -v /path/to/conf:/opt/hadoop/etc/hadoop -p 9870:9870 -p 8088:8088 -p 19888:19888 -p 8042:8042 -p 9864:9864 --restart on-failure gsiopen/hadoop:3.2.1
~~~

## Environment variables

The environment configuration is controlled via the following environment variable groups or PREFIX:

    XML_CORE: affects core-site.xml
    XML_HDFS: affects hdfs-site.xml
    XML_HTTPFS: affects httpfs-site.xml
    XML_YARN: affects yarn-site.xml
    XML_CAPACITY_SCHEDULER: affects capacity-scheduler.xml
    XML_MAPRED: affects mapred-site.xml
    XML_KMS: affects kms-site.xml
    XML_KMS_ACLS: affects kms-acls.xml
    XML_HADOOP_POLICY: affects hadoop-policy.xml

Set environment variables with the appropriated group in the form PREFIX_PROPERTY.

Due to restriction imposed by docker and docker-compose on environment variable names the following substitution are applied to PROPERTY names:

    _ => .
    __ => _
    ___ => -

Following are some illustratory examples:

    XML_HDFS_dfs_replication: sets the dfs.replication property in hdfs-site.xml
    XML_YARN_yarn_log___aggregation___enable: sets the yarn.log-aggregation-enable property in yarn-site.xml
    
# License

View [license information](https://github.com/apache/hadoop/blob/trunk/LICENSE.txt) for the software contained in this image.

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.
