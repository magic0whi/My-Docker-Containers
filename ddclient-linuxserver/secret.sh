[ ! -d config ] && mkdir config

FILENAME=ddclient.conf
env $(cat secret.env) envsubst < ${FILENAME}.sample > config/${FILENAME}
