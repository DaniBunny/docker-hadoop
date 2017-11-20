#!/bin/bash

service ssh start
/opt/hadoop/sbin/start-dfs.sh
/opt/hadoop/sbin/start-yarn.sh
chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
service mysql start

/bin/bash
