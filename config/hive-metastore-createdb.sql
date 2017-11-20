DROP DATABASE IF EXISTS metastore;
CREATE DATABASE metastore;
USE metastore;
SOURCE /opt/hive/scripts/metastore/upgrade/mysql/hive-schema-2.1.0.mysql.sql
