FROM debian:stretch-slim as rest-server

ARG REST_SERVER_VER

RUN TANGO_REST_DOWNLOAD_URL=https://github.com/tango-controls/rest-server/releases/download/rest-server-${REST_SERVER_VER}/rest-server-${REST_SERVER_VER}.jar \
        && buildDeps='ca-certificates wget' \
        && DEBIAN_FRONTEND=noninteractive apt-get update \
        && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends $buildDeps \
        && mkdir -p /usr/local/bin \
        && cd /usr/local/bin \
        && wget -O rest-server.jar "$TANGO_REST_DOWNLOAD_URL"  \
        && apt-get purge -y --auto-remove $buildDeps

FROM tangocs/tango-cs:9.3.3-rc1
COPY --from=rest-server /usr/local/bin usr/local/bin

RUN runtimeDeps='ca-certificates openjdk-8-jre-headless' \
    && sudo mkdir -p /usr/share/man/man1 \
    && DEBIAN_FRONTEND=noninteractive sudo apt-get update \
    && DEBIAN_FRONTEND=noninteractive sudo apt-get -y install --no-install-recommends $runtimeDeps

COPY rest.conf      /etc/supervisor/conf.d/
#COPY tango-test.conf      /etc/supervisor/conf.d/


ENV LD_LIBRARY_PATH=/usr/local/lib
ENV ORB_PORT=10000
ENV TANGO_HOST=127.0.0.1:${ORB_PORT}

EXPOSE ${ORB_PORT}

USER root

ENTRYPOINT /usr/local/bin/wait-for-it.sh $MYSQL_HOST --timeout=30 --strict -- \
    /usr/bin/supervisord -c /etc/supervisord.conf

