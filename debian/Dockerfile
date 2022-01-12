ARG OSVERSION=latest
FROM debian:${OSVERSION}
ARG VERSION=
ARG PIES_TAG=
ARG XENV_TAG=
ENV DEBIAN_FRONTEND=noninteractive
ARG BUILD_DEPS="build-essential git rsync wget autopoint automake autoconf bison flex"
RUN apt-get -qq update && \
    apt-get -qq install \
             m4 ${BUILD_DEPS}
WORKDIR /usr/src
ARG PREFIX=/pies
RUN git clone http://git.gnu.org.ua/pies.git
WORKDIR /usr/src/pies
RUN if [ -n "${PIES_TAG}" ]; then git checkout ${PIES_TAG}; fi
RUN ./bootstrap
RUN ./configure --prefix=${PREFIX}\
          --sysconfdir=${PREFIX}/conf\
	  --disable-sysvinit\
	  --without-pp-setup\
	  DEFAULT_INCLUDE_PATH=${PREFIX}/conf\
	  DEFAULT_PREPROCESSOR="/pies/bin/xenv -s" &&\
    make INFO_DEPS= && \
    make INFO_DEPS= install
WORKDIR /usr/src
RUN git clone http://git.gnu.org.ua/xenv.git
WORKDIR /usr/src/xenv
RUN if [ -n "${XENV_TAG}" ]; then git checkout ${XENV_TAG}; fi
RUN make PREFIX=${PREFIX} LEXFLAGS= install-bin
WORKDIR ${PREFIX}
RUN mkdir ${PREFIX}/conf ${PREFIX}/conf.d
COPY pies.conf ${PREFIX}/conf
COPY rc ${PREFIX}/conf
ENV PATH="/pies/sbin:/pies/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENTRYPOINT ["/pies/conf/rc"]
EXPOSE 8073
RUN rm -rf /usr/src/*
RUN apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false ${BUILD_DEPS} && \
 rm -rf /var/lib/apt/lists/*
ARG CREATEDTIME
ARG PIES_VERSION
ARG XENV_VERSION
LABEL org.opencontainers.image.title="GNU Pies docker image"
LABEL org.opencontainers.image.documentation="Base for creating images with components managed by GNU Pies"
LABEL org.opencontainers.version="${VERSION}"
LABEL org.opencontainers.image.authors="Sergey Poznyakoff <gray@gnu.org>"
LABEL org.opencontainers.image.url="https://github.com/graygnuorg/docker-pies"
LABEL org.opencontainers.image.source="https://github.com/graygnuorg/docker-pies"
LABEL org.opencontainers.vendor="Sergey Poznyakoff"
LABEL org.opencontainers.image.licenses="GPLv3+"
LABEL org.opencontainers.image.description="pies ${PIES_VERSION}, xenv ${XENV_VERSION}"
LABEL org.opencontainers.image.created="${CREATEDTIME}"
