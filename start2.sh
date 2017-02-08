#!/bin/bash -e

. /opt/b2s/b2s_env

. /etc/env

if [ -x /srv/start/setup.sh ]
then
	. /srv/start/setup.sh
fi

cd /opt/b2s

#FIXME set admin passwords.

asadmin --passwordfile $GFPASSFILE --user admin --port $B2S_DAS_ADMIN_PORT start-domain b2s
asadmin --passwordfile $GFPASSFILE --user admin --port $B2S_DAS_ADMIN_PORT start-local-instance b2sServer


asadmin --passwordfile $GFPASSFILE --user admin --port $B2S_DAS_ADMIN_PORT set resources.jdbc-connection-pool.b2s_cp.property.ServerName=$PGSERVER
asadmin --passwordfile $GFPASSFILE --user admin --port $B2S_DAS_ADMIN_PORT set resources.jdbc-connection-pool.b2s_cp.property.PortNumber=$PGPORT
asadmin --passwordfile $GFPASSFILE --user admin --port $B2S_DAS_ADMIN_PORT set resources.jdbc-connection-pool.b2s_cp.property.Password=$(awk -F: '{if($4=="user_cond"){print $5}}' /opt/b2s/.pgpass) 2>/dev/null
asadmin --passwordfile $GFPASSFILE --user admin --port $B2S_DAS_ADMIN_PORT set resources.jdbc-connection-pool.b2sAdm_cp.property.ServerName=$PGSERVER
asadmin --passwordfile $GFPASSFILE --user admin --port $B2S_DAS_ADMIN_PORT set resources.jdbc-connection-pool.b2sAdm_cp.property.PortNumber=$PGPORT
asadmin --passwordfile $GFPASSFILE --user admin --port $B2S_DAS_ADMIN_PORT set resources.jdbc-connection-pool.b2sAdm_cp.property.Password=$(awk -F: '{if($4=="user_cond"){print $5}}' /opt/b2s/.pgpass) 2>/dev/null
asadmin --passwordfile $GFPASSFILE --user admin --port $B2S_DAS_ADMIN_PORT restart-domain b2s
asadmin --passwordfile $GFPASSFILE --user admin --port $B2S_DAS_ADMIN_PORT restart-local-instance b2sServer

asadmin --user admin --passwordfile $GFPASSFILE --port $B2S_DAS_ADMIN_PORT deploy --target b2sServer ./b2s.war

#tail -f /opt/payara41/glassfish/domains/b2s/logs/server.log &
tail -f /opt/payara41/glassfish/nodes/localhost-b2s/b2sServer/logs/server.log &

#FIXME it would be nice to have a better way then this.
while true; do
	ps ax | grep java | grep -v grep > /dev/null || exit 0; 
	sleep 5
done
