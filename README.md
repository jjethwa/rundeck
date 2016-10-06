rundeck
==============

This repository contains the source for the [Rundeck](http://rundeck.org/) [docker](https://docker.io) image.

# Image details

1. Based on debian:jessie
1. Supervisor, Apache2, and rundeck
1. No SSH.  Use docker exec or [nsenter](https://github.com/jpetazzo/nsenter)
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

# Rundeck plugins
To add (external) plugins, add the jars to the /opt/rundeck-plugins volume and they will be copied over to Rundeck's libext directory at container startup

# Environment variables

| Variable     |      Description      |  Default value |
|:------------:|-----------------------|:--------------:|
| **SERVER_URL** |  Full URL in the form http://MY.HOSTNAME.COM:4440, http//123.456.789.012:4440, etc | `https://0.0.0.0:4443` |
| **EXTERNAL_SERVER_URL** |    Use this if you are running rundeck behind a proxy.  This is useful if you run rundeck through some kind of external network gateway/load balancer.  Note that utilities like rd-jobs and rd-projects will no longer work and you will need to use the newer [rd](https://github.com/rundeck/rundeck-cli) command line utility.   |   `$SERVER_URL` |
| **RDECK_JVM** | Additional parameters sent to the rundeck JVM (ex: -Dserver.web.context=/rundeck) ||
| **RUNDECK_UID** | The unix user ID to be used for the rundeck account when rundeck is booted.  This is useful for embedding this docker container into your development environment sharing files via docker volumes between the container and your host OS.  RUNDECK_GID also needs to be defined for this overload to take place. | |
| **RUNDECK_GID** | The unix group ID to be used for the rundeck account when rundeck is booted.  This is useful for embedding this docker container into your development environment sharing files via docker volumes between the container and your host OS.  RUNDECK_UID also needs to be defined for this overload to take place. | |
| **DATABASE_NAME** | MySQL database name | `rundeckdb` |
| **DATABASE_USER** | MySQL database username | `runback` |
| **DATABASE_PASSWORD** | MySQL user password | Random: `$(pwgen -s 15 1)` |
| **DATABASE_HOST** | MySQL server hostname | `localhost` |
| **DATABASE_PORT** | MySQL server port | `3306` |
| **DATABASE_URL** | For use with (container) external database | `jdbc:mysql://${DATABASE_HOST}/${DATABASE_NAME}?autoReconnect=true` |
| **RUNDECK_STORAGE_PROVIDER** | Options `file` or `db`. For more info check the [docs](http://rundeck.org/docs/plugins-user-guide/configuring.html#storage-plugins). | `file` |
| **RUNDECK_PROJECT_STORAGE_TYPE** | Options `file` or `db`. For more info check the [docs](http://rundeck.org/docs/administration/setting-up-an-rdb-datasource.html). | `file` |
| **RUNDECK_ADMIN_PASSWORD** | The rundeck server admin password | `admin` |
| **DEBIAN_SYS_MAINT_PASSWORD** | MySQL password for debian-sys-maint user | Random: `$(pwgen -s 15 1)` |
| **NO_LOCAL_MYSQL** | Set to true if using an external MySQL container or instance.  Make sure to set `DATABASE_NAME`/`DATABASE_USER`/`DATABASE_PASSWORD`/`DATABASE_HOST`/`DATABASE_PORT` as needed. For more info check the [docs](http://rundeck.org/docs/administration/setting-up-an-rdb-datasource.html). | `false` |

# Volumes

```
/etc/rundeck
/var/rundeck
/var/lib/rundeck - Not recommended to use as a volume as it contains webapp.  For SSH key you can use the this volume: /var/lib/rundeck/.ssh
/var/lib/mysql
/var/log/rundeck
/opt/rundeck-plugins - For adding external plugins
/var/lib/rundeck/logs
/var/lib/rundeck/var/storage
```

# Using an SSL Terminated Proxy
See: http://rundeck.org/docs/administration/configuring-ssl.html#using-an-ssl-terminated-proxy
