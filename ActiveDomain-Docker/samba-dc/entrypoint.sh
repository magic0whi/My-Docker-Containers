#!/bin/sh -e

if [ ! -f /etc/timezone ] && [ ! -z "${TZ}" ]; then
  echo 'Set timezone'
  cp /usr/share/zoneinfo/${TZ} /etc/localtime
  echo ${TZ} >/etc/timezone
fi

if [ ${RUN_TYPE} == "samba-dc" ]; then
  REALM=$(echo "${REALM}" | tr [a-z] [A-Z])
  DNS_BACKEND=$(echo "${DNS_BACKEND}" | tr [a-z] [A-Z])
  
  if [ ! -f /var/lib/samba/registry.tdb ]; then
    if [ ! -f /run/secrets/${ADMIN_PASSWORD_SECRET} ]; then
      echo 'Cannot read secret ${ADMIN_PASSWORD_SECRET} in /run/secrets'
      exit 1
    fi
    ADMIN_PASSWORD=$(cat /run/secrets/${ADMIN_PASSWORD_SECRET})
    if [ "${BIND_INTERFACES_ONLY}" == "yes" ]; then
      INTERFACE_OPTS="--option=\"bind interfaces only=yes\" \
        --option=\"interfaces=${INTERFACES}\" --host-ip=${HOSTIP} --host-ip6=${HOSTIP6}"
    fi
    if [ ${DOMAIN_ACTION} == "provision" ]; then
      PROVISION_OPTS="--server-role=dc --use-rfc2307 --domain=${WORKGROUP} \
      --realm=${REALM} --adminpass='${ADMIN_PASSWORD}'"
    elif [ ${DOMAIN_ACTION} == "join" ]; then
      PROVISION_OPTS="${REALM} DC -UAdministrator --password='${ADMIN_PASSWORD}'"
    else
      echo 'Only provision and join actions are supported.'
      exit 1
    fi
  
    rm -f /etc/samba/smb.conf /etc/krb5.conf
    echo "samba-tool domain ${DOMAIN_ACTION} ${INTERFACE_OPTS} ${PROVISION_OPTS} \
       --dns-backend=${DNS_BACKEND}" | sh
  fi
  
  ln -sf /var/lib/samba/private/krb5.conf /etc/
  
  exec samba --model=${MODEL} -i </dev/null
elif [ ${RUN_TYPE} == "bind-dc" ]; then
  exec named -c /etc/bind/named.conf -g
elif [ ${RUN_TYPE} == "chrony-dc" ]; then
  # Folder permissions are not necessary because chronyd is run as root
  # chown root:chrony /usr/local/samba/var/lib/ntp_signd/
  # chmod 750 /var/lib/samba/ntp_signd/
  exec chronyd -d -s
else
  echo 'Only samba-dc and bind-dc and chrony-dc types are supported.'
  exit 1
fi