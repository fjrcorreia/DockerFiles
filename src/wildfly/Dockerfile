##
## Wildfly on a small image
##
## deploy for maven projects can use wildfly plugin
## https://docs.jboss.org/wildfly/plugins/maven/latest
##

## Using the smallest image of the moment
FROM fcorreia/openjdk:alpine

MAINTAINER  Francisco Correia <fjrcorreia@github.com>


# Set the WILDFLY_VERSION env variable
ENV WILDFLY_VERSION 10.0.0.Final
ENV WILDFLY_SHA1 c0dd7552c5207b0d116a9c25eb94d10b4f375549
ENV JBOSS_HOME  /opt/wildfly

## for jboss listen to the term signal
ENV LAUNCH_JBOSS_IN_BACKGROUND 1


RUN wget http://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-${WILDFLY_VERSION}.tar.gz \
    && sha1sum wildfly-$WILDFLY_VERSION.tar.gz | grep ${WILDFLY_SHA1} \
    && tar -xzf wildfly-${WILDFLY_VERSION}.tar.gz \
    && mkdir /opt && mv wildfly-${WILDFLY_VERSION} /opt/wildfly \
    && usermod -d /opt/wildfly -l wildfly -c "JBoss Wildfly User" app-user \
    && chown -R wildfly. ${JBOSS_HOME} \
    && mkdir /docker-init.d

ADD scripts/wildfly-launch.sh /opt/wildfly/bin/launch.sh

## Service, Administration and Debug port
## to enable debug start container with standalone.sh --debug
EXPOSE 8080 9990 8787

USER wildfly

CMD ["/opt/wildfly/bin/launch.sh"]
