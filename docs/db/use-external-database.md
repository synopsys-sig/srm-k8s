# Use an External MariaDB instance for your SRM database

Here are the steps required to use SRM with an external database:

>Note: SRM currently requires [MariaDB version 10.6.x](https://mariadb.com/kb/en/release-notes-mariadb-106-series/).

1. Create a database user for SRM. You can customize the following statement to create
   an SRM database user named srm (remove 'REQUIRE SSL' when not using TLS).

   CREATE USER 'srm'@'%' IDENTIFIED BY 'enter-a-password-here' REQUIRE SSL;

2. Apply any database configuration changes necessary to allow remote database connections. 

3. Create an SRM database. The following statement creates an SRM database named srmdb.

   CREATE DATABASE srmdb;

4. Grant required privileges on the SRM database to the database user you created. The
   following statements grant permissions to the srm database user.

   GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, CREATE TEMPORARY TABLES, ALTER, REFERENCES, INDEX, DROP, TRIGGER ON srmdb.* to 'srm'@'%';
   FLUSH PRIVILEGES;

5. Set the following MariaDB variables. Failure to complete this step will negatively affect SRM performance or functionality.

```
[mysqld]
optimizer_search_depth=0
character-set-server=utf8mb4
collation-server=utf8mb4_general_ci
lower_case_table_names=1
log_bin_trust_function_creators=1
```

>Note: The log_bin_trust_function_creators parameter is required when using MariaDB SQL replication.

6. Restart your MariaDB instance.
