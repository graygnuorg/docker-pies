ARG OSVERSION=latest
FROM alpine:${OSVERSION}
ARG BUILD_DEPS="alpine-sdk git autoconf automake gettext gettext-dev rsync coreutils bison flex"
RUN apk add ${BUILD_DEPS} m4
WORKDIR /usr/src
ARG PREFIX=/pies
ARG PIES_TAG=
ARG XENV_TAG=
RUN git clone http://git.gnu.org.ua/pies.git
WORKDIR /usr/src/pies
RUN if [ -n "${PIES_TAG}" ]; then git checkout ${PIES_TAG}; fi
RUN ./bootstrap
RUN ./configure --prefix=${PREFIX}\
          --sysconfdir=${PREFIX}/conf\
	  --disable-sysvinit\
	  --disable-nls\
	  --without-pp-setup\
	  DEFAULT_INCLUDE_PATH=${PREFIX}/conf\
	  DEFAULT_PREPROCESSOR="/pies/bin/xenv -s" &&\
    make INFO_DEPS= && \
    make INFO_DEPS= install && \
    rm -rf ${PREFIX}/share/locale/
WORKDIR /usr/src
RUN git clone http://git.gnu.org.ua/xenv.git
WORKDIR /usr/src/xenv
RUN if [ -n "${XENV_TAG}" ]; then git checkout ${XENV_TAG}; fi
RUN make PREFIX=${PREFIX} install-bin
WORKDIR ${PREFIX}
RUN mkdir ${PREFIX}/conf ${PREFIX}/conf.d
COPY pies.conf ${PREFIX}/conf
COPY rc ${PREFIX}/conf
ENV PATH="/pies/sbin:/pies/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENTRYPOINT ["/pies/conf/rc"]
EXPOSE 8073
RUN rm -rf /usr/src/*
RUN apk del ${BUILD_DEPS}
ARG VERSION
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


