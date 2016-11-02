# Dockerfile for rundeck
# https://github.com/jjethwa/rundeck

FROM debian:jessie

MAINTAINER Jordan Jethwa

ENV DEBIAN_FRONTEND noninteractive \
    SERVER_URL https://localhost:4443 \
    RUNDECK_STORAGE_PROVIDER file \
    RUNDECK_PROJECT_STORAGE_TYPE file \
    NO_LOCAL_MYSQL false

RUN echo "deb http://ftp.debian.org/debian jessie-backports main" >> /etc/apt/sources.list && \
    apt-get -qq update && \
    apt-get -qqy install --no-install-recommends bash openjdk-8-jre-headless supervisor procps sudo ca-certificates openssh-client mysql-server mysql-client pwgen curl git && \
    cd /tmp/ && \
    curl -Lo /tmp/rundeck.deb http://dl.bintray.com/rundeck/rundeck-deb/rundeck-2.6.9-1-GA.deb && \
    echo '363c64a7643ae2e52db6b9d019c8593835123327959ae35c95050708d122066f  rundeck.deb' > /tmp/rundeck.sig && \
    shasum -a256 -c /tmp/rundeck.sig && \
    curl -Lo /tmp/rundeck-cli.deb https://github.com/rundeck/rundeck-cli/releases/download/v0.1.19/rundeck-cli_0.1.19-1_all.deb && \
    echo 'd863ec0e011252ae46751136ff87991b975a21100767264df4c1a77b62fe80e5  rundeck-cli.deb' > /tmp/rundeck-cli.sig && \
    shasum -a256 -c /tmp/rundeck-cli.sig && \
    cd - && \
    dpkg -i /tmp/rundeck*.deb && rm /tmp/rundeck*.deb && \
    chown rundeck:rundeck /tmp/rundeck && \
    mkdir -p /var/lib/rundeck/.ssh && \
    chown rundeck:rundeck /var/lib/rundeck/.ssh && \
    sed -i "s/export RDECK_JVM=\"/export RDECK_JVM=\"\${RDECK_JVM} /" /etc/rundeck/profile && \
    curl -Lo /var/lib/rundeck/libext/rundeck-slack-incoming-webhook-plugin-0.6.jar https://github.com/higanworks/rundeck-slack-incoming-webhook-plugin/releases/download/v0.6.dev/rundeck-slack-incoming-webhook-plugin-0.6.jar && \
    echo 'd23b31ec4791dff1a7051f1f012725f20a1e3e9f85f64a874115e46df77e00b5  rundeck-slack-incoming-webhook-plugin-0.6.jar' > /tmp/rundeck-slack-plugin.sig && \
    cd /var/lib/rundeck/libext/ && \
    shasum -a256 -c /tmp/rundeck-slack-plugin.sig && \
    cd - && \
    apt-get clean && \
    apt-get autoremove -y curl git && \
    rm -rf /var/lib/apt/lists/*

ADD content/ /
RUN chmod u+x /opt/run && \
    mkdir -p /var/log/supervisor && mkdir -p /opt/supervisor && \
    chmod u+x /opt/supervisor/rundeck && chmod u+x /opt/supervisor/mysql_supervisor

EXPOSE 4440 4443

VOLUME  ["/etc/rundeck", "/var/rundeck", "/var/lib/rundeck", "/var/lib/mysql", "/var/log/rundeck", "/opt/rundeck-plugins", "/var/lib/rundeck/logs", "/var/lib/rundeck/var/storage"]

ENTRYPOINT ["/opt/run"]
