##
##
##
FROM alpine:latest

MAINTAINER Francisco Correia <fjrcorreia@github.com>


RUN apk add --update openssl && \
    wget https://nodejs.org/dist/v4.4.1/node-v4.4.1.tar.gz \
    -O /tmp/node-src.tar.gz &&  mkdir -p /tmp/build && \
    cd /tmp/build && tar -xzf /tmp/node-src.tar.gz && \
    rm /tmp/node-src.tar.gz && cd /tmp/build/node-v4.4.1 && \
    apk add --no-cache curl make gcc g++ binutils-gold python linux-headers \
    paxctl libgcc libstdc++ gnupg && \
    cd /tmp/build/node-v4.4.1  && ./configure && make && make install && \
    cd / && rm -rf /tmp/build && \
    apk del binutils binutils-gold binutils-libs ca-certificates curl db expat \
    g++ gcc gdbm gmp gnupg isl libassuan libatomic libattr libbz2 libc-dev \
    libcap libffi libgcrypt libgomp libgpg-error libksba libldap libsasl \
    libssh2 libuv-dev linux-headers make mpc1 mpfr3 musl-dev ncurses-libs \
    ncurses-terminfo ncurses-terminfo-base npth openssh openssh-client \
    openssh-sftp-server openssl paxctl pinentry pkgconf pkgconfig python \
    readline sqlite-libs


# RUN apk add --update nodejs libgcc libstdc++ libuv

##ENTRYPOINT ["/usr/bin/node"]

CMD ["/usr/local/bin/node"]
