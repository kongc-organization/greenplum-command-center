# Using Greenplum with S3 extensions to access external data - Minio, distributed object storage
[![Build Status](https://travis-ci.org/kongc-organization/greenplum-minio.svg?branch=master)](https://travis-ci.org/kongc-organization/greenplum-minio)
This readme describes how to configure [Greenplum](greenplum.org) and [Minio](https://minio.io/) and uses [S3 extension](https://gpdb.docs.pivotal.io/570/admin_guide/external/g-s3-protocol.html) to access objects that are stored inside Minio.

Feel free to propose changes and improvements.

## Pre-requisites

1. [docker-compose](https://docs.docker.com/compose/)
1. [Minio docker image](https://hub.docker.com/r/minio/minio/)
1. [GPDB open source docker image](https://hub.docker.com/r/kochanpivotal/gpdb5oss/)

This document assumes you have basic working knowledge to use docker, docker-compose and Linux/Mac terminal.

## How to run docker-compose
By default, [docker-compose-minio.yml](minio/docker-compose-minio.yml) configures both Greenplum and Minio instances. You can change the settings by editing the yml file.

To run this docker-compose, type the command below in the root directory. If you are running this command for the first time, it downloads all the required images from hub.docker.com.

```
$ ./runDocker.sh -t minio -c up
Creating minio4     ... done
Creating minio1     ... done
Creating minio3     ... done
Creating minio2      ... done
Creating gpdb-minio  ... done
Creating minioclient ... done
Attaching to minio3, minio4, minio1, minio2, gpdb-minio, minioclient
minio3         | Created minio configuration file successfully at /root/.minio
minio1         | Created minio configuration file successfully at /root/.minio
minio4         | Created minio configuration file successfully at /root/.minio
minio2         | Created minio configuration file successfully at /root/.minio
minio1         |
```

## How to verify Minio instance

1. Use your browser to access this URL [http://localhost:9001/minio/login](http://localhost:9001/minio/login).

2. Enter "minio" for Access Key. Enter "minio123" for Secret Key.

3. Verify the minio console shows 3 files are created.

```
read_stocks.sql
stocks.csv
testdata.csv    
```


## How to access Greenplum docker instance

1. Use docker command to access GPDB docker instance.
```
$ docker exec -it gpdb-minio bash
 root@gpdb-minio:/#
```

2. Use "startGPDB.sh" script to start Greenplum instance

```
root@gpdb-minio:/# startGPDB.sh
SSHD isn't running
 * Starting OpenBSD Secure Shell server sshd                                                 [ OK ]
SSHD is running...
20180413:18:59:52:000084 gpstart:gpdb-minio:gpadmin-[INFO]:-Starting gpstart with args: -a
20180413:18:59:52:000084 gpstart:gpdb-minio:gpadmin-[INFO]:-Gathering information and validating the environment...
20180413:18:59:52:000084 gpstart:gpdb-minio:gpadmin-[INFO]:-Greenplum Binary Version: 'postgres (Greenplum Database) 5.5.0 build 67afa18-oss'
20180413:18:59:52:000084 gpstart:gpdb-minio:gpadmin-[INFO]:-Greenplum Catalog Version: '301705051'
20180413:18:59:52:000084 gpstart:gpdb-minio:gpadmin-[INFO]:-Starting Master instance in admin mode
20180413:18:59:54:000084 gpstart:gpdb-minio:gpadmin-[INFO]:-Obtaining Greenplum Master catalog information
20180413:18:59:54:000084 gpstart:gpdb-minio:gpadmin-[INFO]:-Obtaining Segment details from master...
20180413:18:59:54:000084 gpstart:gpdb-minio:gpadmin-[INFO]:-Setting new master era
20180413:18:59:54:000084 gpstart:gpdb-minio:gpadmin-[INFO]:-Master Started...
20180413:18:59:55:000084 gpstart:gpdb-minio:gpadmin-[INFO]:-Heap checksum setting is consistent across the cluster
20180413:18:59:55:000084 gpstart:gpdb-minio:gpadmin-[INFO]:-Shutting down master
...
```
3. Verify Greenplum process is running by running `ps -elf | grep gpdb`

```
root@gpdb-minio:/# ps -elf | grep gpdb
5 S gpadmin    197     0  0  80   0 - 108576 -     18:59 ?        00:00:00 /opt/gpdb/bin/postgres -D /gpdata/segments/gpseg0 -p 40000 --gp_dbid=2 --gp_num_contents_in_cluster=2 --silent-mode=true -i -M mirrorless --gp_contentid=0
5 S gpadmin    198     0  0  80   0 - 108576 -     18:59 ?        00:00:00 /opt/gpdb/bin/postgres -D /gpdata/segments/gpseg1 -p 40001 --gp_dbid=3 --gp_num_contents_in_cluster=2 --silent-mode=true -i -M mirrorless --gp_contentid=1
5 S gpadmin    229     0  0  80   0 - 98064 -      18:59 ?        00:00:00 /opt/gpdb/bin/postgres -D /gpdata/master/gpseg-1 -p 5432 --gp_dbid=1 --gp_num_contents_in_cluster=2 --silent-mode=true -i -M master --gp_contentid=-1 -x 0 -E
0 S root       278    18  0  80   0 -  3235 -      19:01 pts/1    00:00:00 grep --color=auto gpdb
```


## How to read data from Minio via GPDB - S3 extension
This section describes how to enable S3 protocol on GPDB, followed by creating sample external table that points to Minio object storage.

1. Create s3 configuration for Greenplum.
The example below creates `s3.conf` under /home/gpadmin and uses access key and secret key for Minio server.

```
[gpadmin@127.0.0.1]$ cat <<EOF > /home/gpadmin/s3.conf
[default]
secret = "minio123"
accessid = "minio"
threadnum = 6
chunksize = 671088654
loglevel = DEBUG
encryption = false
version = 2
EOF
```
2. Verify the S3.conf is working by using gpcloudcheck.

```
$ gpcheckcloud -c "s3://minio1:9000/testbucket/ config=/home/gpadmin/s3.conf"
File: read_stocks.sql, Size: 1759
File: stocks.csv, Size: 12246
File: testdata.csv, Size: 138
```

3. Next, you can enable S3 Protocol on gpdb

Use psql on the Greenplum docker instance.

```
docker exec -it gpdb-minio bash
 root@gpdb-minio:/#
root@gpdb-minio:/code/minio/S3Examples# psql -h localhost -U gpadmin gpadmin
psql (9.5.12, server 8.3.23)
Type "help" for help.
gpadmin=#
```

4. Type these commands to create read and write function for S3

`CREATE OR REPLACE FUNCTION read_from_s3() RETURNS integer AS'$libdir/gps3ext.so','s3_import' LANGUAGE C STABLE;`

`CREATE OR REPLACE FUNCTION write_to_s3() RETURNS integer AS '$libdir/gps3ext.so', 's3_export' LANGUAGE C STABLE;`

`CREATE PROTOCOL s3 (writefunc = write_to_s3,readfunc = read_from_s3);`


```
psql (9.5.12, server 8.3.23)
Type "help" for help.

gpadmin=# CREATE OR REPLACE FUNCTION read_from_s3() RETURNS integer AS
gpadmin-#     '$libdir/gps3ext.so', 's3_import' LANGUAGE C STABLE;
CREATE FUNCTION
gpadmin=# -- Declare the S3 protocol and specify the function that is used
gpadmin=# -- to read from an S3 bucket
gpadmin=# CREATE PROTOCOL s3 (writefunc = write_to_s3,readfunc = read_from_s3);
ERROR:  protocol "s3" already exists
CREATE PROTOCOL
gpadmin=# CREATE OR REPLACE FUNCTION write_to_s3() RETURNS integer AS
gpadmin-# '$libdir/gps3ext.so', 's3_export'
gpadmin-# LANGUAGE C STABLE;
CREATE FUNCTION
```
5. Create external table that refers to Minio instance that uses the hostname `minio1` with port 9000

```
gpadmin=# CREATE EXTERNAL TABLE stock_fact_external (
gpadmin(# stock text,
gpadmin(# stock_date text,
gpadmin(# price text
gpadmin(# )
gpadmin-# LOCATION('s3://minio1:9000/testbucket/stocks.csv config=/home/gpadmin/s3.conf')
gpadmin-# FORMAT 'TEXT'(DELIMITER=',');
CREATE EXTERNAL TABLE
gpadmin=#
```

6. Verify that Greenplum can read data from Minio via S3 external table.

The following command loads data from Minio server via S3 protocol and displays the results.

```
gpadmin=# select count(*) from stock_fact_external;
 count
-------
   561
(1 row)
gpadmin=# select * from stock_fact_external limit 10;
 stock  | stock_date | price
--------+------------+-------
 symbol | date       | price
 MSFT   | Jan 1 2000 | 39.81
 MSFT   | Feb 1 2000 | 36.35
 MSFT   | Mar 1 2000 | 43.22
 MSFT   | Apr 1 2000 | 28.37
 MSFT   | May 1 2000 | 25.45
 MSFT   | Jun 1 2000 | 32.54
 MSFT   | Jul 1 2000 | 28.4
 MSFT   | Aug 1 2000 | 28.4
 MSFT   | Sep 1 2000 | 24.53
(10 rows)
```
