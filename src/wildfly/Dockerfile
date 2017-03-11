##
## Wildfly on a small image
##
## deploy for maven projects can use wildfly plugin
## https://docs.jboss.org/wildfly/plugins/maven/latest
##

## Using the smallest image of the moment
FROM fcorreia/openjdk:alpine

MAINTAINER  Francisco Correia <francisco.correia.pt@gmail.com>


# Set the WILDFLY_VERSION env variable
ENV WILDFLY_VERSION 10.1.0.Final
ENV WILDFLY_SHA1    9ee3c0255e2e6007d502223916cefad2a1a5e333
ENV JBOSS_HOME      /opt/wildfly

## for jboss listen to the term signal
ENV LAUNCH_JBOSS_IN_BACKGROUND 1


RUN wget http://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-${WILDFLY_VERSION}.tar.gz \
    && sha1sum wildfly-$WILDFLY_VERSION.tar.gz | grep ${WILDFLY_SHA1} \
    && tar -xzf wildfly-${WILDFLY_VERSION}.tar.gz \
    && mkdir /opt && mv wildfly-${WILDFLY_VERSION} /opt/wildfly \
    && usermod -d /opt/wildfly -l wildfly -c "JBoss Wildfly User" app-user \
    && chown -R wildfly. ${JBOSS_HOME} \
    && mkdir /docker-init.d \
    && apk update \
    && apk add ca-certificates \
    && update-ca-certificates \
    && if [ -e "/var/cache/apk" ]; then rm -rf /var/cache/apk; fi

ADD scripts/wildfly-launch.sh /opt/wildfly/bin/launch.sh

## Service, Administration and Debug port
EXPOSE 8080 9990 8787

USER wildfly


## For debug mode, set the following environment variables
##
## DEBUG=true - to enable debug
##
CMD ["/opt/wildfly/bin/launch.sh"]
