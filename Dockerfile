# Dockerfile for rundeck
# https://github.com/jjethwa/rundeck

FROM debian:stretch

MAINTAINER Jordan Jethwa

ENV SERVER_URL=https://localhost:4443 \
    RUNDECK_STORAGE_PROVIDER=file \
    RUNDECK_PROJECT_STORAGE_TYPE=file \
    NO_LOCAL_MYSQL=false \
    LOGIN_MODULE=RDpropertyfilelogin \
    JAAS_CONF_FILE=jaas-loginmodule.conf \
    KEYSTORE_PASS=adminadmin \
    TRUSTSTORE_PASS=adminadmin \
    CLUSTER_MODE=false

RUN export DEBIAN_FRONTEND=noninteractive && \
    echo "deb http://ftp.debian.org/debian stretch-backports main" >> /etc/apt/sources.list && \
    apt-get -qq update && \
    apt-get -qqy install -t stretch-backports --no-install-recommends bash openjdk-8-jre-headless ca-certificates-java supervisor procps sudo ca-certificates openssh-client mysql-server mysql-client postgresql-9.6 postgresql-client-9.6 pwgen curl git uuid-runtime parallel jq && \
    cd /tmp/ && \
    curl -Lo /tmp/rundeck.deb https://dl.bintray.com/rundeck/rundeck-deb/rundeck_3.3.0.20200701-1_all.deb && \
    echo '32810690f81387b214b61e4351f406c4571952b14ffc7e5fad7891d63e76c8aa  rundeck.deb' > /tmp/rundeck.sig && \
    shasum -a256 -c /tmp/rundeck.sig && \
    curl -Lo /tmp/rundeck-cli.deb https://dl.bintray.com/rundeck/rundeck-deb/rundeck-cli_1.3.0-1_all.deb && \
    echo '0a385275403d40cc76900fd6b16a7c00786899c1aace9364a9ecd2865ff792ae  rundeck-cli.deb' > /tmp/rundeck-cli.sig && \
    shasum -a256 -c /tmp/rundeck-cli.sig && \
    cd - && \
    dpkg -i /tmp/rundeck*.deb && rm /tmp/rundeck*.deb && \
    mkdir -p /tmp/rundeck && \
    chown rundeck:rundeck /tmp/rundeck && \
    mkdir -p /var/lib/rundeck/.ssh && \
    chown rundeck:rundeck /var/lib/rundeck/.ssh && \
    sed -i "s/export RDECK_JVM=\"/export RDECK_JVM=\"\${RDECK_JVM} /" /etc/rundeck/profile && \
    curl -Lo /var/lib/rundeck/libext/rundeck-slack-incoming-webhook-plugin-0.11.jar https://github.com/higanworks/rundeck-slack-incoming-webhook-plugin/releases/download/v0.11.dev/rundeck-slack-incoming-webhook-plugin-0.11.jar && \
    echo 'efce8fa7891371bb8540b55d7eef645741566d411b3dbed43e9b7fe2e4d099a0  rundeck-slack-incoming-webhook-plugin-0.11.jar' > /tmp/rundeck-slack-plugin.sig && \
    cd /var/lib/rundeck/libext/ && \
    shasum -a256 -c /tmp/rundeck-slack-plugin.sig && \
    cd - && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD content/ /
RUN chmod u+x /opt/run && \
    mkdir -p /var/log/supervisor && mkdir -p /opt/supervisor && \
    chmod u+x /opt/supervisor/rundeck && chmod u+x /opt/supervisor/mysql_supervisor && chmod u+x /opt/supervisor/fatalservicelistener

EXPOSE 4440 4443

VOLUME  ["/etc/rundeck", "/var/rundeck", "/var/lib/mysql", "/var/log/rundeck", "/opt/rundeck-plugins", "/var/lib/rundeck/logs", "/var/lib/rundeck/var/storage"]

ENTRYPOINT ["/opt/run"]
