FROM alpine:3.13

RUN apk add --no-cache \
    wget \
    autoconf \
    automake \
    make \
    g++ \
    libtool \
    boost-dev \
    libevent-dev \
    db-dev \
    pkgconf

RUN wget https://github.com/bitcoin/bitcoin/archive/refs/tags/v0.21.1.tar.gz
RUN tar xzf *.tar.gz
RUN cd bitcoin* && \
    ./autogen.sh && \
    ./configure --disable-tests --disable-bench --with-incompatible-bdb && \
    make -j 8 && \
    make install
RUN mkdir -p /root/bitcoind-simnet/
