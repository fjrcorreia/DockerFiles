
FROM alpine:latest

MAINTAINER  Francisco Correia <fjrcorreia@github.com>


ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8


RUN apk add shadow --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/  \
    && apk add ca-certificates  --update-cache \
    && update-ca-certificates \
    && apk add openssl \
    && rm -rf /var/cache/apk/*

## Add system user on a group out of normal scope for container ruuning service usage
RUN addgroup -S -g 65535 service \
    && adduser -D -H -S -u 65535 -G service -s /sbin/nologin -h /opt/service app-user
