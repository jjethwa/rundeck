# Dockerfile for sonatype-nexus
# https://github.com/jjethwa/nexus

FROM debian:wheezy

MAINTAINER Jordan Jethwa

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -qq update && apt-get -qqy upgrade && apt-get -qqy install --no-install-recommends supervisor procps sudo ca-certificates openjdk-7-jre-headless && apt-get clean

ADD http://www.sonatype.org/downloads/nexus-latest-bundle.tar.gz /tmp/nexus.tar
RUN tar xfv /tmp/nexus.tar -C /opt && rm /tmp/nexus.tar
RUN /usr/sbin/useradd --create-home --home-dir /home/nexus --shell /bin/bash nexus
RUN ln -s `find /opt -maxdepth 1 -type d -iname "nexus-*"` /opt/nexus

RUN chown -R nexus.nexus /opt/sonatype-work `find /opt -maxdepth 1 -type d -iname "nexus-*"`

# Supervisor
RUN mkdir -p /var/log/supervisor && mkdir -p /opt/supervisor
ADD nexus.conf /etc/supervisor/conf.d/nexus.conf
ADD nexus_supervisor /opt/supervisor/nexus_supervisor
RUN chmod u+x /opt/supervisor/nexus_supervisor && chown nexus.nexus /opt/supervisor/nexus_supervisor

EXPOSE 8081

VOLUME  ["/opt/sonatype-work", "/opt/nexus/conf"]

# Start Supervisor
CMD ["/usr/bin/supervisord"]
