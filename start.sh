#! /bin/bash

# Config file moves transferred from Dockerfile to support
# binding /etc/apcupsd to user-specified host directory

# Check if apcupsd.conf already exists
if [ ! -f /etc/apcupsd/apcupsd.conf ]; then
  mv /usr/local/bin/apcupsd          /etc/default/apcupsd \
  && mv /usr/local/bin/apcupsd.conf /etc/apcupsd/apcupsd.conf \
  && mv /usr/local/bin/hosts.conf   /etc/apcupsd/hosts.conf \
  && mv /usr/local/bin/doshutdown   /etc/apcupsd/doshutdown
else
  mv /usr/local/bin/apcupsd          /etc/default/apcupsd \
  && mv /usr/local/bin/hosts.conf   /etc/apcupsd/hosts.conf \
  && mv /usr/local/bin/doshutdown   /etc/apcupsd/doshutdown
fi

# Check if UPSNAME environment variable is set, and if so update apcupsd.conf
if [ ! -z $UPSNAME ]; then
  sed -i 's|^UPSNAME.*|UPSNAME '"$UPSNAME"'|' /etc/apcupsd/apcupsd.conf
  echo "UPSNAME set to: \"$UPSNAME\""
fi

# Check if UPSCABLE environment variable is set, and if so update apcupsd.conf
if [ ! -z $UPSCABLE ]; then
  sed -i 's|^UPSCABLE.*|UPSCABLE '"$UPSCABLE"'|' /etc/apcupsd/apcupsd.conf
  echo "UPSCABLE set to: \"$UPSCABLE\""
fi

# Check if UPSTYPE environment variable is set, and if so update apcupsd.conf
if [ ! -z $UPSTYPE ]; then
  sed -i 's|^UPSTYPE.*|UPSTYPE '"$UPSTYPE"'|' /etc/apcupsd/apcupsd.conf
  echo "UPSTYPE set to: \"$UPSTYPE\""
fi

# Check if DEVICE environment variable is set, and if so update apcupsd.conf
if [ ! -z $DEVICE ]; then
  sed -i 's|^#DEVICE /dev/tty0.*|DEVICE '"$DEVICE"'|' /etc/apcupsd/apcupsd.conf
  echo "DEVICE set to: \"$DEVICE\""
fi

# Check if NETSERVER environment variable is set, and if so update apcupsd.conf
if [ ! -z $NETSERVER ]; then
  sed -i 's|^NETSERVER.*|NETSERVER '"$NETSERVER"'|' /etc/apcupsd/apcupsd.conf
  echo "NETSERVER set to: \"$NETSERVER\""
fi

# Check if NISIP environment variable is set, and if so update apcupsd.conf
if [ ! -z $NISIP ]; then
  sed -i 's|^NISIP.*|NISIP '"$NISIP"'|' /etc/apcupsd/apcupsd.conf
  echo "NISIP set to: \"$NISIP\""
fi

# Check if NISPORT environment variable is set, and if so update apcupsd.conf
if [ ! -z $NISPORT ]; then
  sed -i 's|^NISPORT.*|NISPORT '"$NISPORT"'|' /etc/apcupsd/apcupsd.conf
  echo "NISPORT set to: \"$NISPORT\""
fi

/sbin/apcupsd -b