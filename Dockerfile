# Dockerfile for rundeck
# https://github.com/jjethwa/rundeck

FROM debian:jessie

MAINTAINER Jordan Jethwa

ENV DEBIAN_FRONTEND noninteractive
ENV SERVER_URL https://localhost:4443
ENV RUNDECK_STORAGE_PROVIDER file
ENV RUNDECK_PROJECT_STORAGE_TYPE file
ENV NO_LOCAL_MYSQL false

RUN echo "deb http://ftp.debian.org/debian jessie-backports main" >> /etc/apt/sources.list && apt-get -qq update && apt-get -qqy upgrade && apt-get -qqy install --no-install-recommends bash openjdk-8-jre-headless supervisor procps sudo ca-certificates openssh-client mysql-server mysql-client pwgen curl git && apt-get clean

RUN curl -Lo /tmp/rundeck.deb http://dl.bintray.com/rundeck/rundeck-deb/rundeck-2.6.9-1-GA.deb
RUN curl -Lo /tmp/rundeck-cli.deb https://github.com/rundeck/rundeck-cli/releases/download/v0.1.19/rundeck-cli_0.1.19-1_all.deb

ADD content/ /

RUN dpkg -i /tmp/rundeck*.deb && rm /tmp/rundeck*.deb
RUN chown rundeck:rundeck /tmp/rundeck
RUN chmod u+x /opt/run
RUN mkdir -p /var/lib/rundeck/.ssh
RUN chown rundeck:rundeck /var/lib/rundeck/.ssh

# Supervisor
RUN mkdir -p /var/log/supervisor && mkdir -p /opt/supervisor
RUN chmod u+x /opt/supervisor/rundeck && chmod u+x /opt/supervisor/mysql_supervisor

# Give a chance to customize default installation
RUN sed -i "s/export RDECK_JVM=\"/export RDECK_JVM=\"\${RDECK_JVM} /" /etc/rundeck/profile

# Slack plugin
RUN curl -Lo /var/lib/rundeck/libext/rundeck-slack-incoming-webhook-plugin-0.6.jar https://github.com/higanworks/rundeck-slack-incoming-webhook-plugin/releases/download/v0.6.dev/rundeck-slack-incoming-webhook-plugin-0.6.jar

EXPOSE 4440 4443

VOLUME  ["/etc/rundeck", "/var/rundeck", "/var/lib/rundeck", "/var/lib/mysql", "/var/log/rundeck", "/opt/rundeck-plugins"]

# Start Supervisor
ENTRYPOINT ["/opt/run"]
