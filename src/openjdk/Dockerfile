#
# Smallest jdk 8
#
FROM fcorreia/base:alpine

MAINTAINER  Francisco Correia <fjrcorreia@github.com>



## Java Environment variables
ENV JAVA_HOME  /usr/lib/jvm/default-jvm
ENV CLASSPATH  .:/usr/lib/jvm/default-jvm/lib


## use repository version
RUN apk add openjdk8 --update-cache \
    && rm -rf /var/cache/apk/*
