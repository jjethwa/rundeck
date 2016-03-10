rundeck
==============

This repository contains the source for the [Rundeck](http://rundeck.org/) [docker](https://docker.io) image.

# Image details

1. Based on debian:wheezy
1. Supervisor, Apache2, and rundeck
1. No SSH.  Use [nsenter](https://github.com/jpetazzo/nsenter)
1. If RUNDECK_PASSWORD is not supplied, it will be randomly generated and shown via stdout.
1. Supply the SERVER_URL or else you won't get too far :)
1. As always, update passwords for pre-installed accounts
1. I sometimes get connection reset by peer errors when building the Docker image from the Rundeck download URL.  Trying again usually works.


# Automated build

```
docker pull jordan/rundeck
```

# Usage
Start a new container and bind to host's port 4440

```
sudo docker run -p 4440:4440 -e SERVER_URL=http://MY.HOSTNAME.COM:4440 -t jordan/rundeck:latest
```

# Environment variables

```
SERVER_URL - Full URL in the form http://MY.HOSTNAME.COM:4440, http//123.456.789.012:4440, etc

RDECK_JVM - Additional parameters sent to the rundeck JVM (ex: -Dserver.web.context=/rundeck)

DATABASE_URL - For use with (container) external database

RUNDECK_PASSWORD - MySQL 'rundeck' user password

RUNDECK_STORAGE_PROVIDER - Options file (default) or db.  See: http://rundeck.org/docs/plugins-user-guide/configuring.html#storage-plugins

RUNDECK_PROJECT_STORAGE_TYPE - Options file (default) or db.  See: http://rundeck.org/docs/administration/setting-up-an-rdb-datasource.html

DEBIAN_SYS_MAINT_PASSWORD

NO_LOCAL_MYSQL - false (default).  Set to true if using an external MySQL container or instance.  Make sure to set DATABASE_URL and RUNDECK_PASSWORD (used for JDBC connection to MySQL).  Further details for setting up MYSQL: http://rundeck.org/docs/administration/setting-up-an-rdb-datasource.html
```

# Volumes

```
/etc/rundeck
/var/rundeck
/var/lib/rundeck - Not recommended to use as a volume as it contains webapp.  For SSH key you can use the this volume: /var/lib/rundeck/.ssh
/var/lib/mysql
/var/log/rundeck
```
