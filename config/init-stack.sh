hdfs dfs -mkdir /user
hdfs dfs -mkdir /user/root
hdfs dfs -chmod 777 /user/root
hdfs dfs -mkdir /user/hive
hdfs dfs -chmod 777 /user/hive
hdfs dfs -mkdir /user/hive/warehouse
hdfs dfs -chmod 777 /user/hive/warehouse
hdfs dfs -mkdir /tmp
hdfs dfs -chmod 777 /tmp
hdfs dfs -mkdir /tmp/hive
hdfs dfs -chmod 777 /tmp/hive
hdfs dfs -ls -R /

nohup hive --service metastore &

echo "------------------------------------------------------------------------"
echo "Simple docker Hadoop/YARN/Hive/Spark"
echo "------------------------------------------------------------------------"
echo "For Hive and just type hive or beeline" 
echo "For Spark Scala:       spark-shell --master yarn --deploy-mode client"
echo "For Spark Python 3.5:  pyspark --master yarn --deploy-mode client"
echo "------------------------------------------------------------------------"
