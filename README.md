# Hadoop/Hive/Spark (Single Node) using Docker on Windows from scratch.

By using this docker image you will have a **Hadoop 2.7.4, Hive 2.1.1 and Spark 2.2.0 Single Node** container ready for development / testing / debug porpuses.

You could then easily change this code to whatever need you have.

I've used Windows 10 on decent hardware (4 cores, 16GB RAM) with a 2 core/8GB RAM sized docker installation.

Run /root/set-env.sh and /root/init-stack.sh and have fun!

## What's bundled?

Java 8
Hadoop HDFS/Mapred and YARN version 2.7.4
Hive 2.1.1 with MySQL datastore and spark execution engine
Spark 2.2.0 with YARN and Hive Support
PySpark 3.5 and Spark-Shell (Scala)

## For impatient people.

The first time will take many minutes to download the image.

### To start the container (very impatient people).

```
docker run --name my-hadoop-2.7.4 -it -P danibunny/docker-hadoop-hive-spark:2.7.4-single
```

After this, you will be right inside of the hadoop docker container bash terminal.

If you want to execute a hadoop example, for example:
```
/opt/hadoop/bin/hdfs dfs -ls -R /
/opt/hadoop/bin/hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.4.jar pi 16 100000
/opt/hadoop/bin/hdfs dfs -ls -R /
```

### To start the container (for the less impatient).

```
docker run --name my-hadoop-hive-docker \
  -p 50070:50070 \
  -p 50075:50075 \
  -p 50060:50060 \
  -p 50030:50030 \
  -p 19888:19888 \
  -p 10033:10033 \
  -p 8032:8032 \
  -p 8030:8030 \
  -p 8088:8088 \
  -p 8033:8033 \
  -p 8042:8042 \
  -p 8188:8188 \
  -p 8047:8047 \
  -p 8788:8788 \
  -it danibunny/docker-hadoop-hive-spark:2.7.4-single
```

After this, you will be right inside of the hadoop docker container bash terminal.

### TODO

1 - Change Hive execution engine to Spark
