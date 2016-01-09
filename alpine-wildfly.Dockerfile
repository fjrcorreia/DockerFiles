##
## Wildfly on a small image
##

## Using the smallest image of the moment
FROM alpine:latest

MAINTAINER  Francisco Correia <fjrcorreia@github.com>

## for jboss listen to the term signal
ENV LAUNCH_JBOSS_IN_BACKGROUND 1

ADD scripts/prepare-wildfly.sh      /sbin/prepare-wildfly.sh

RUN apk update && \
    apk add bash openjdk8 && \
    /sbin/prepare-wildfly.sh


EXPOSE 8080 9990

USER wildfly

CMD ["/opt/wildfly/bin/standalone.sh"]
