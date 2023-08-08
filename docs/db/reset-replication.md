# Reset MariaDB Replication for your SRM database

Here are the steps that use four terminal windows to reset MariaDB database replication (when not using an external database):

>Note: The steps assume two statefulsets named srm-mariadb-master and srm-mariadb-slave and a deployment named srm-web in the srm namespace with one subordinate database. It also assumes a database named codedx.

Terminal 1 (Subordinate DB):

1.	kubectl -n srm scale --replicas=0 deployment/srm-web
2.	kubectl -n srm exec -it srm-mariadb-slave-0 -- bash
3.	mysql -uroot -p
4.	STOP SLAVE;
5.	exit # mysql

Terminal 2 (Master DB):

6.	kubectl -n srm exec -it srm-mariadb-master-0 -- bash
7.	mysql -uroot -p
8.	RESET MASTER;
>Note: RESET MASTER deletes previous binary log files, creating a new binary log file.
9.	FLUSH TABLES WITH READ LOCK;

Terminal 3 (Master DB):

10.	kubectl -n srm exec -it srm-mariadb-master-0 -- bash
11.	mysqldump -u root -p codedx > /bitnami/mariadb/srm-dump.sql

>Note: The above command assumes you have adequate space at /bitnami/mariadb to store your database backup. Use an alternate path as necessary, and adjust paths in subsequent steps accordingly.

Terminal 2 (Master DB)

12.	UNLOCK TABLES;

Terminal 4:

13.	kubectl -n srm cp srm-mariadb-master-0:/bitnami/mariadb/srm-dump.sql ./srm-dump.sql
14.	kubectl -n srm cp ./srm-dump.sql srm-mariadb-slave-0:/bitnami/mariadb/srm-dump.sql

Terminal 1 (Subordinate DB):

15.	mysql -u root -p codedx < /bitnami/mariadb/srm-dump.sql
16.	mysql -uroot -p
17.	RESET SLAVE;
>Note: RESET SLAVE deletes relay log files.
18. Remove old binary log files by running "SHOW BINARY LOGS;" and "PURGE BINARY LOGS TO 'name';"
>Note: If you previously deleted binary log files (mysql-bin.000*) from the file system, remove the contents of the mysql-bin.index text file.
19.	CHANGE MASTER TO MASTER_LOG_FILE='mysql-bin.000001', MASTER_LOG_POS=1;
20.	START SLAVE;
21.	SHOW SLAVE STATUS \G;
22.	exit # mysql
23.	rm /bitnami/mariadb/srm-dump.sql
24.	exit # pod
25.	exit # terminal

Terminal 2 (Master DB):

26.	exit # mysql
27.	rm /bitnami/mariadb/srm-dump.sql
28.	exit # pod
29.	exit # terminal

Terminal 3 (Master DB):

30.	exit # pod
31.	exit # terminal

Terminal 4:

32.	kubectl -n srm scale --replicas=1 deployment/srm-web
33.	exit # terminal

