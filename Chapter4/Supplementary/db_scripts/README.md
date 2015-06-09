### db_scripts


This folder is a collection of scripts used to initialize, manage and configure advanced options of the HSQLDB database used for Chapter4 project.

In particular:

- [initdb.sql](initdb.sql) is setting multiversioning control (MVCC) and disables db log, in order to augment insert performance.
- [server-start.sh](server-start.sh) is configuring the server to run in a cluster environment as well as loading the JavaCL Java Stored Procedure ([proc-hom-sp](../proc-hom-sp)).

