FROM ubuntu:latest
MAINTAINER Greg Ewing (https://github.com/gregewing)
ENV LANG=C.UTF-8 DEBIAN_FRONTEND=noninteractive TZ= UPSNAME= UPCABLE= UPSTYPE= DEVICE= POLLTIME= ONBATTERYDELAY= BATTERYLEVEL= MINUTES= TIMEOUT= SELFTEST= APCUPSD_SLAVES=

COPY scripts /usr/local/bin

RUN echo Starting. \
 && apt-get -q -y update \
 && apt-get -q -y install --no-install-recommends apcupsd dbus libapparmor1 libdbus-1-3 libexpat1 tzdata\
 && apt-get -q -y full-upgrade \
 && rm -rif /var/lib/apt/lists/* \
 && mv /usr/local/bin/apcupsd         /etc/default/apcupsd \
 && mv /usr/local/bin/apcupsd.conf    /etc/apcupsd/apcupsd.conf \
 && mv /usr/local/bin/hosts.conf      /etc/apcupsd/hosts.conf \
 && mv /usr/local/bin/doshutdown      /etc/apcupsd/doshutdown \
 && echo Finished.

CMD ["/sbin/apcupsd", "-b"]
