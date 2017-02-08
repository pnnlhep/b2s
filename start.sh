#!/bin/bash

PGSERVER=${PGSERVER:=127.0.0.1}
PGPORT=${PGPORT:=5432}
USER_NAME=${USER_NAME:=payara}
USER_UID=${USER_UID:=1000}
USER_GID=${USER_GID:=1000}

B2S_INITIAL_MEM=${B2S_INITIAL_MEM:=8192}
B2S_MAX_MEM=${B2S_MAX_MEM:=8192}

echo PGSERVER=$PGSERVER > /etc/env
echo PGPORT=$PGPORT >> /tmp/env
echo B2S_INITIAL_MEM=${B2S_INITIAL_MEM}m >> /tmp/env
echo B2S_MAX_MEM=${B2S_MAX_MEM}m >> /tmp/env

adduser --quiet --disabled-password --home /opt/payara41/ --shell /bin/bash --no-create-home --uid $USER_UID --gid $USER_GID $USER_NAME

find / -mount -user 1000 -exec chown $USER_UID.$USER_GID {} \; > /dev/null
su -s /bin/bash - $USER_NAME /etc/start2.sh
