FROM tangocs/rest-server:rest-server-1.14 as rest-server

FROM tangocs/tango-cs:9.3.2-alpha.1

RUN echo "deb [check-valid-until=no] http://archive.debian.org/debian jessie-backports main" > /etc/apt/sources.list.d/jessie-backports.list

RUN echo "Acquire::Check-Valid-Until \"false\";" >> /etc/apt/apt.conf

USER root

RUN rm /usr/local/lib/libtango.so.9

RUN rm /usr/local/lib/liblog4tango.so.5

RUN ln -s /usr/local/lib/libtango.so.9.3.2 /usr/local/lib/libtango.so.9

RUN ln -s /usr/local/lib/liblog4tango.so.5.0.1 /usr/local/lib/liblog4tango.so.5



RUN apt-get update && apt-get install -t jessie-backports -y openjdk-8-jre-headless

RUN mkdir -p /usr/local/lib/tango

COPY --from=rest-server /home/rest/rest-server-1.14.jar /usr/local/lib/tango

#TODO ssl-cert

COPY rest.conf /etc/supervisor/conf.d

