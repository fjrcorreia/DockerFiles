
FROM alpine:latest

MAINTAINER  Francisco Correia <fjrcorreia@github.com>


ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8


RUN apk add sudo --update-cache && \
    apk add shadow --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/

## Add system user
RUN addgroup -S -g 65535 service \
    && adduser -D -H -S -u 65535 -G service -s /sbin/nologin -h /opt/service app-user

## Add administrator user
RUN adduser -h /home/manager -s /bin/sh -g 1000 -u 1000 -D manager && \
    usermod -a -G service manager  && \
    sed '/^root ALL=/c\manager ALL=(ALL) NOPASSWD: ALL' -i /etc/sudoers
