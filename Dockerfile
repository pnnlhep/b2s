FROM payara/server-full
MAINTAINER Kevin Fox "Kevin.Fox@pnnl.gov"

USER root
RUN apt-get update -y; apt-get install -y postgresql-client
ADD ./b2s_0.5.1.tar.gz /opt
#FIXME pull binaries from somewhere else.
#FIXME add passwordfile thing to the create_domain script native.
RUN mkdir -p /opt && \
cd /opt && \
chown --recursive payara.payara /opt/b2s && \
sed -i "s@\(/opt/payara41\)_b2s@\1@g" /opt/b2s/b2s_env && \
rm -f /b2s_0.5.1.tar.gz && \
mkdir -p /srv/belle2_conddb && \
chown --recursive payara.payara /srv

USER payara
RUN cd /opt/b2s && \
bash -xe create_domain.sh && \
. ./b2s_env && \
asadmin --user admin --passwordfile $GFPASSFILE --port $B2S_DAS_ADMIN_PORT stop-domain b2s && \
asadmin --user admin --passwordfile $GFPASSFILE --port $B2S_DAS_ADMIN_PORT stop-local-instance b2sServer

USER root

ADD ./start.sh /etc/start.sh
ADD ./start2.sh /etc/start2.sh
RUN chmod +x /etc/start*.sh

CMD ["/etc/start.sh"]
