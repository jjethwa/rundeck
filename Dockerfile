# Dockerfile for rundeck
# https://github.com/jjethwa/rundeck

FROM debian:wheezy

MAINTAINER Jordan Jethwa

ENV DEBIAN_FRONTEND noninteractive
ENV SERVER_URL http://localhost:4440

RUN apt-get -qq update && apt-get -qqy upgrade && apt-get -qqy install --no-install-recommends supervisor procps sudo ca-certificates openjdk-7-jre-headless openssh-client mysql-server mysql-client pwgen && apt-get clean

ADD http://dl.bintray.com/rundeck/rundeck-deb/rundeck-2.2.1-1-GA.deb /tmp/rundeck.deb

RUN dpkg -i /tmp/rundeck.deb && rm /tmp/rundeck.deb
RUN chown rundeck:rundeck /tmp/rundeck
ADD run /opt/run
RUN chmod u+x /opt/run
RUN mkdir -p /var/lib/rundeck/.ssh
RUN chown rundeck:rundeck /var/lib/rundeck/.ssh

# Supervisor
RUN mkdir -p /var/log/supervisor && mkdir -p /opt/supervisor
ADD rundeck.conf /etc/supervisor/conf.d/rundeck.conf
ADD rundeck /opt/supervisor/rundeck
ADD mysql_supervisor /opt/supervisor/mysql_supervisor
RUN chmod u+x /opt/supervisor/rundeck && chmod u+x /opt/supervisor/mysql_supervisor

# Fix for boot2docker VM issue
RUN chmod 1777 /tmp

EXPOSE 4440

VOLUME  ["/etc/rundeck", "/var/rundeck", "/var/lib/mysql"]

# Start Supervisor
ENTRYPOINT ["/opt/run"]
