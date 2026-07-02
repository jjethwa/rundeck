# Dockerfile for rundeck
# https://github.com/jjethwa/rundeck

FROM debian:trixie

MAINTAINER Jordan Jethwa

ENV SERVER_URL=https://localhost:4443 \
    RUNDECK_STORAGE_PROVIDER=db \
    NO_LOCAL_MYSQL=false \
    LOGIN_MODULE=RDpropertyfilelogin \
    JAAS_CONF_FILE=jaas-loginmodule.conf \
    KEYSTORE_PASS=adminadmin \
    TRUSTSTORE_PASS=adminadmin \
    CLUSTER_MODE=false

RUN export DEBIAN_FRONTEND=noninteractive && \
    echo "deb http://ftp.debian.org/debian trixie-backports main" >> /etc/apt/sources.list && \
    apt-get -qq update && \
    apt-get -qqy install -t trixie-backports --no-install-recommends apt-transport-https curl ca-certificates && \
    curl -LsS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | bash -s -- --mariadb-server-version=11.8.8 && \
    apt-get -qqy install -t trixie-backports --no-install-recommends bash openjdk-25-jre-headless ca-certificates-java supervisor procps sudo openssh-client mariadb-server mariadb-client postgresql postgresql-client pwgen git uuid-runtime parallel jq libxml2-utils html2text unzip && \
    curl -s https://packagecloud.io/install/repositories/pagerduty/rundeck/script.deb.sh | os=any dist=any bash && \
    apt-get -qqy install rundeck rundeck-cli && \
    mkdir -p /tmp/rundeck && \
    chown rundeck:rundeck /tmp/rundeck && \
    mkdir -p /var/lib/rundeck/.ssh && \
    chown rundeck:rundeck /var/lib/rundeck/.ssh && \
    sed -i "s/export RDECK_JVM=\"/export RDECK_JVM=\"\${RDECK_JVM} /" /etc/rundeck/profile && \
    curl -Lo /var/lib/rundeck/libext/slack-incoming-webhook-plugin-2.0.0.jar https://github.com/rundeck-plugins/slack-incoming-webhook-plugin/releases/download/2.0.0/slack-incoming-webhook-plugin-2.0.0.jar && \
    echo '8a785cda19dd6d80ba1c816921d9554ba2742f62f4f1fa45f8bdfd8b658f9b1d  slack-incoming-webhook-plugin-2.0.0.jar' > /tmp/rundeck-slack-plugin.sig && \
    cd /var/lib/rundeck/libext/ && \
    shasum -a256 -c /tmp/rundeck-slack-plugin.sig && \
    cd - && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD content/ /
RUN chmod u+x /opt/run && \
    mkdir -p /var/log/supervisor && mkdir -p /opt/supervisor && \
    chmod u+x /opt/supervisor/rundeck && chmod u+x /opt/supervisor/mariadb_supervisor && chmod u+x /opt/supervisor/fatalservicelistener

EXPOSE 4440 4443

VOLUME  ["/etc/rundeck", "/var/rundeck", "/var/lib/mysql", "/var/log/rundeck", "/opt/rundeck-plugins", "/var/lib/rundeck/logs", "/var/lib/rundeck/var/storage"]

ENTRYPOINT ["/opt/run"]
