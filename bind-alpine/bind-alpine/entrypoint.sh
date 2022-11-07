#!/bin/sh -e

if [ ! -f /etc/timezone ] && [ ! -z "${TZ}" ]; then
  echo 'Set timezone'
  cp /usr/share/zoneinfo/${TZ} /etc/localtime
  echo ${TZ} >/etc/timezone
fi

exec named -c /etc/bind/named.conf -g