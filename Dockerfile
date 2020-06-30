FROM ubuntu:14.04

MAINTAINER KiwenLau <kiwenlau@gmail.com>
ADD sources.list /etc/apt/sources.list
ADD apache-hive-2.1.1-bin.tar.gz /
ADD mysql-connector-java-5.1.38.jar /
ADD hadoop-2.7.2.tar.gz /
COPY config/* /tmp/

WORKDIR /root

# install openssh-server, openjdk and wget,install hadoop 2.7.2
RUN apt-get update && \
    apt-get install -y --reinstall software-properties-common && \
    add-apt-repository -y ppa:openjdk-r/ppa && \
    apt-get update && \
    apt-get install -y openssh-server openjdk-8-jdk && \
    apt-get clean all && \
    mv /hadoop-2.7.2 /usr/local/hadoop && \
    mv /apache-hive-2.1.1-bin /usr/local/hive && \
    cp /mysql-connector-java-5.1.38.jar /usr/local/hive/lib/ && \
    apt-get -y --purge remove software-properties-common

# set environment variable
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_HOME=/usr/local/hadoop
ENV HIVE_HOME=/usr/local/hive
ENV PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin 

# ssh without key and hadoop config
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    mkdir -p ~/hdfs/namenode && \ 
    mkdir -p ~/hdfs/datanode && \
    mkdir $HADOOP_HOME/logs && \
    mv /tmp/ssh_config ~/.ssh/config && \
    mv /tmp/hadoop-env.sh /usr/local/hadoop/etc/hadoop/hadoop-env.sh && \
    mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \ 
    mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && \
    mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    mv /tmp/slaves $HADOOP_HOME/etc/hadoop/slaves && \
    mv /tmp/start-hadoop.sh ~/start-hadoop.sh && \
    mv /tmp/run-wordcount.sh ~/run-wordcount.sh && \
    mv /tmp/hive-site.xml /usr/local/hive/conf/ && \
    chmod +x ~/start-hadoop.sh && \
    chmod +x ~/run-wordcount.sh && \
    chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh && \
    /usr/local/hadoop/bin/hdfs namenode -format

# format namenode
#RUN /usr/local/hadoop/bin/hdfs namenode -format

CMD [ "sh", "-c", "service ssh start; bash"]

