DROP USER IF EXISTS 'hive'@'%';
CREATE USER 'hive'@'%' IDENTIFIED BY 'hiverulez';
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'hive'@'%';
GRANT SELECT,INSERT,UPDATE,DELETE,LOCK TABLES,EXECUTE ON metastore.* TO 'hive'@'%';
FLUSH PRIVILEGES;
