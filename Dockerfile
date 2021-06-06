ARG OSVERSION=10
FROM debian:${OSVERSION}
ENV DEBIAN_FRONTEND=noninteractive
ARG PREFIX=/pies
ARG BUILD_DEPS="build-essential git rsync wget autopoint automake autoconf bison flex"
RUN apt-get -qq update && \
    apt-get -qq install \
             m4 ${BUILD_DEPS}
WORKDIR /usr/src
RUN git clone http://git.gnu.org.ua/pies.git
WORKDIR /usr/src/pies
RUN ./bootstrap
RUN ./configure --prefix=${PREFIX} && \
    make INFO_DEPS= && \
    make INFO_DEPS= install
WORKDIR /usr/src
RUN git clone http://git.gnu.org.ua/xenv.git
WORKDIR /usr/src/xenv
RUN make PREFIX=${PREFIX} install
WORKDIR ${PREFIX}
RUN mkdir -p ${PREFIX}/etc/pies.d ${PREFIX}/share/pies/include
COPY pies.conf ${PREFIX}/etc
RUN find ${PREFIX}/share/pies -name pp-setup -delete
COPY pp-setup ${PREFIX}/share/pies/include
COPY rc ${PREFIX}/etc
ENTRYPOINT ["/pies/etc/rc"]
EXPOSE 8073
RUN apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false ${BUILD_DEPS} && \
 rm -rf /var/lib/apt/lists/*

    

