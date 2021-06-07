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
RUN ./configure --prefix=${PREFIX}\
          --sysconfdir=${PREFIX}/conf\
	  DEFAULT_PREPROCESSOR="/pies/bin/xenv -s" &&\
    make INFO_DEPS= && \
    make INFO_DEPS= incdir=${PREFIX}/conf install
WORKDIR /usr/src
RUN git clone http://git.gnu.org.ua/xenv.git
WORKDIR /usr/src/xenv
RUN make PREFIX=${PREFIX} install
WORKDIR ${PREFIX}
RUN mkdir ${PREFIX}/conf.d
RUN find ${PREFIX}/conf -name pp-setup -delete
COPY pies.conf ${PREFIX}/conf
COPY rc ${PREFIX}/conf
ENTRYPOINT ["/pies/conf/rc"]
EXPOSE 8073
RUN rm -rf /usr/src/*
RUN apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false ${BUILD_DEPS} && \
 rm -rf /var/lib/apt/lists/*

    

