# Pivotal Greenplum
The Pivotal Greenplum Database (GPDB) is an advanced, fully featured, open source data warehouse. It provides powerful and rapid analytics on petabyte scale data volumes. Uniquely geared toward big data analytics, Greenplum Database is powered by the world’s most advanced cost-based query optimizer delivering high analytical query performance on large data volumes.

<https://pivotal.io/pivotal-greenplum>


# Minio
[Minio](https://minio.io/) is a high performance distributed object storage server, designed for
large-scale private cloud infrastructure. Minio is widely deployed across the
world

<https://minio.io/>

# Table of Contents
1. [Pre-requisites](#Pre-requisites)
2. [Using docker-compose](#Using docker-compose)
3. [Connect to Greenplum and Minio with S3 protocol](#Connect to Greenplum and Minio with S3 protocol)
4. [Read data from Minio](#Read data from Minio)

## Pre-requisites:
- [docker-compose](http://docs.docker.com/compose)
- [Minio docker image](https://hub.docker.com/r/minio/minio/)
- [GPDB 5.x OSS docker image](https://hub.docker.com/r/kochanpivotal/gpdb5oss/)

# Using docker-compose
1. First, make sure you have installed [docker](https://www.docker.com/get-docker) on your machine. Next you use docker to install pre-created image with Greenplum Open Source binaries. For example, if you run the command below, it will download the latest image and run the instance.

```
docker run -it --hostname=gpdb5oss --name gpdb5oss --publish 5432:5432 --publish 88:22 kochanpivotal/gpdb5oss bin/bash
```

2. To access `Greenplum cluster`, exec into a container:
```
    $ docker exec -it gpdb5oss bash
```
## Configure Minio with some data

##  Connect to Greenplum and Minio with S3 protocol
In this example, you can learn how to configure S3 extension in Greenplum.


```

## Conclusions
Greenplum-Spark connector uses Greenplum gpfdist protocol to parallelize data transfer between Greenplum and Spark clusters. Therefore, this connector provides better read throughput, compared to typical JDBC driver.

## License
MIT






```
cat <<EOF > /home/gpadmin/s3.conf
[default]
secret = "minio123"
accessid = "minio"
threadnum = 4
chunksize = 67108864
low_speed_limit = 10240
low_speed_time = 60
encryption = false
# true
version = 2
proxy = ""
autocompress = true
verifycert = false
# true
server_side_encryption = ""
# gpcheckcloud config
gpcheckcloud_newline = "\n"
EOF
```

```
[gpadmin@gpdbsne ~]$ gpcheckcloud -c "s3://minio1:9000/testbucket config=/home/gpadmin/s3.conf"
File: read_stocks.sql, Size: 586
File: stocks.csv, Size: 12246
File: testdata.csv, Size: 138
```

```
[gpadmin@gpdbsne ~]$ cat s3.conf
[default]
secret = "minio123"
accessid = "minio"
threadnum = 4
chunksize = 67108864
low_speed_limit = 10240
low_speed_time = 60
encryption = false
# true
version = 2
proxy = ""
autocompress = true
verifycert = false
# true
server_side_encryption = ""
# gpcheckcloud config
gpcheckcloud_newline = "\n"
```
