FROM ubuntu:latest
MAINTAINER Daniel Coelho <daniel.bunny@gmail.com>

USER root
WORKDIR /root

ENV HADOOP_VERSION 2.7.4
ENV HADOOP_PREFIX /opt/hadoop
ENV HIVE_VERSION 2.1.1
ENV HIVE_PREFIX /opt/hive
ENV MYSQL_PWD sparkrulez
RUN echo "mysql-server mysql-server/root_password password $MYSQL_PWD" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password $MYSQL_PWD" | debconf-set-selections
ENV SPARK_VERSION 2.2.0
ENV SPARK_PREFIX /opt/spark


# Install all dependencies

RUN apt-get update && apt-get install -y wget ssh rsync openjdk-8-jdk vim mysql-server libmysql-java

# Install root ssh key
COPY config/ssh_config /root/.ssh/config 
RUN chmod 0600 /root/.ssh/config
RUN ssh-keygen -q -t rsa -P '' -f /root/.ssh/id_rsa \
    && cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys \
    && chmod 0600 /root/.ssh/authorized_keys \
    && chmod 0600 /root/.ssh/id_rsa.pub \
    && chmod 0600 /root/.ssh \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3 10

####### Hadoop Base

# Download hadoop.
RUN wget -O /tmp/hadoop-${HADOOP_VERSION}.tar.gz http://mirrors.whoishostingthis.com/apache/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz 

# Install hadoop
RUN tar -C /opt -xf /tmp/hadoop-${HADOOP_VERSION}.tar.gz \
    && ln -s /opt/hadoop-${HADOOP_VERSION} ${HADOOP_PREFIX} \
    && mkdir /var/lib/hadoop

# Copy Hadoop config files
COPY config/hadoop-env.sh ${HADOOP_PREFIX}/etc/hadoop/
COPY config/core-site.xml ${HADOOP_PREFIX}/etc/hadoop/
COPY config/hdfs-site.xml ${HADOOP_PREFIX}/etc/hadoop/
COPY config/mapred-site.xml ${HADOOP_PREFIX}/etc/hadoop/
COPY config/yarn-site.xml ${HADOOP_PREFIX}/etc/hadoop/

# Format hdfs
RUN ${HADOOP_PREFIX}/bin/hdfs namenode -format

# Copy the entry point shell
COPY config/docker_entrypoint.sh /root/
RUN chmod a+x /root/docker_entrypoint.sh

# Folder to share files
RUN mkdir /root/shared && \
    chmod a+rwX /root/shared

####### Hive 

RUN wget -O /tmp/apache-hive-${HIVE_VERSION}-bin.tar.gz http://mirrors.whoishostingthis.com/apache/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz 

# Install Hive
RUN tar -C /opt -xf /tmp/apache-hive-${HIVE_VERSION}-bin.tar.gz \
    && ln -s /opt/apache-hive-${HIVE_VERSION}-bin ${HIVE_PREFIX} \
    && mkdir /var/lib/hive

COPY config/hive-site.xml ${HIVE_PREFIX}/conf/

####### MySQL setup for hive

COPY config/hive-metastore-createdb.sql /root/hive-metastore-createdb.sql
COPY config/hive-metastore-createuser.sql /root/hive-metastore-createuser.sql
RUN ln -s /usr/share/java/mysql.jar ${HIVE_PREFIX}/lib/libmysql-java.jar
RUN mkdir -p /var/lib/mysql \
    && mkdir -p /var/run/mysqld \
    && chown -R mysql:mysql /var/lib/mysql /var/run/mysqld \
    && service mysql start \
    && cd /opt/hive/scripts/metastore/upgrade/mysql \
    && mysql -uroot -psparkrulez < /root/hive-metastore-createdb.sql \
    && mysql -uroot -psparkrulez < /root/hive-metastore-createuser.sql

####### Spark 

RUN wget -O /tmp/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz http://mirrors.whoishostingthis.com/apache/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz

# Install Spark
RUN tar -C /opt -xf /tmp/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz \
    && ln -s /opt/spark-${SPARK_VERSION}-bin-hadoop2.7 ${SPARK_PREFIX} \
    && mkdir /var/lib/spark

# Copy Spark config files
COPY config/spark-env.sh ${SPARK_PREFIX}/conf/

# Link Spark to Hive/Hadoop configs
RUN ln -s ${HADOOP_PREFIX}/etc/hadoop/core-site.xml ${SPARK_PREFIX}/conf/core-site.xml 
RUN ln -s ${HADOOP_PREFIX}/etc/hadoop/hdfs-site.xml ${SPARK_PREFIX}/conf/hdfs-site.xml 
RUN ln -s ${HADOOP_PREFIX}/etc/hadoop/yarn-site.xml ${SPARK_PREFIX}/conf/yarn-site.xml 
RUN ln -s ${HIVE_PREFIX}/conf/hive-site.xml ${SPARK_PREFIX}/conf/hive-site.xml 

# Clean
RUN rm -r /var/cache/apt /var/lib/apt/lists /tmp/hadoop-${HADOOP_VERSION}.tar* /tmp/apache-hive-${HIVE_VERSION}-bin.tar* /tmp/spark-${SPARK_VERSION}-bin*
#RUN rm -r /var/cache/apt /var/lib/apt/lists /tmp/hadoop-${HADOOP_VERSION}.tar*  

COPY config/set-env.sh /root/
COPY config/init-stack.sh /root/

################### Expose ports

### Core

# Zookeeper
EXPOSE 2181

# NameNode metadata service ( fs.defaultFS )
EXPOSE 9000

# FTP Filesystem impl. (fs.ftp.host.port)
EXPOSE 21

### Hdfs ports (Reference: https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-hdfs/hdfs-default.xml)

# NameNode Web UI: Web UI to look at current status of HDFS, explore file system (dfs.namenode.http-address / dfs.namenode.https-address)
EXPOSE 50070 50470

# DataNode : DataNode WebUI to access the status, logs etc. (dfs.datanode.http.address / dfs.datanode.https.address)
EXPOSE 50075 50475

# DataNode  (dfs.datanode.address / dfs.datanode.ipc.address)
EXPOSE 50010 50020

# Secondary NameNode (dfs.namenode.secondary.http-address / dfs.namenode.secondary.https-address)
EXPOSE 50090 50090

# Backup node (dfs.namenode.backup.address / dfs.namenode.backup.http-address)
EXPOSE 50100 50105

# Journal node (dfs.journalnode.rpc-address / dfs.journalnode.http-address / dfs.journalnode.https-address )
EXPOSE 8485 8480 8481

### Mapred ports (Reference: https://hadoop.apache.org/docs/stable/hadoop-mapreduce-client/hadoop-mapreduce-client-core/mapred-default.xml)

# Task Tracker Web UI and Shuffle (mapreduce.tasktracker.http.address)
EXPOSE 50060

# Job tracker Web UI (mapreduce.jobtracker.http.address)
EXPOSE 50030

# Job History Web UI (mapreduce.jobhistory.webapp.address)
EXPOSE 19888

# Job History Admin Interface (mapreduce.jobhistory.admin.address)
EXPOSE 10033

# Job History IPC (mapreduce.jobhistory.address)
EXPOSE 10020

### Yarn ports (Reference: https://hadoop.apache.org/docs/stable/hadoop-yarn/hadoop-yarn-common/yarn-default.xml)

# Applications manager interface (yarn.resourcemanager.address)
EXPOSE 8032

# Scheduler interface (yarn.resourcemanager.scheduler.address)
EXPOSE 8030

# Resource Manager Web UI (yarn.resourcemanager.webapp.address / yarn.resourcemanager.webapp.https.address)
EXPOSE 8088 8090

# ??? (yarn.resourcemanager.resource-tracker.address)
EXPOSE 8031

# Resource Manager Administration Web UI
EXPOSE 8033

# Address where the localizer IPC is (yarn.nodemanager.localizer.address)
EXPOSE 8040

# Node Manager Web UI (yarn.nodemanager.webapp.address)
EXPOSE 8042

# Timeline servise RPC (yarn.timeline-service.address)
EXPOSE 10200

# Timeline servise Web UI (yarn.timeline-service.webapp.address / yarn.timeline-service.webapp.https.address)
EXPOSE 8188 8190

# Shared Cache Manager Admin Web UI (yarn.sharedcache.admin.address)
EXPOSE 8047

# Shared Cache Web UI (yarn.sharedcache.webapp.address)
EXPOSE 8788

# Shared Cache node manager interface (yarn.sharedcache.uploader.server.address)
EXPOSE 8046

# Shared Cache client interface (yarn.sharedcache.client-server.address)
EXPOSE 8045

### Other ports

# SSH
EXPOSE 22


################### Expose volumes
#VOLUME ["/opt/hadoop/logs", "/root/shared"]


################### Entry point
ENTRYPOINT [ "/root/docker_entrypoint.sh" ]
