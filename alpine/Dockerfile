ARG OSVERSION=latest
FROM alpine:${OSVERSION} AS builder
ARG BUILD_DEPS="alpine-sdk git autoconf automake gettext gettext-dev rsync coreutils bison flex"
RUN apk add ${BUILD_DEPS} m4
WORKDIR /usr/src
ARG PREFIX=/pies
ARG PIES_TAG=
ARG XENV_TAG=
RUN git clone http://git.gnu.org.ua/pies.git
WORKDIR /usr/src/pies
RUN if [ -n "${PIES_TAG}" ]; then git checkout ${PIES_TAG}; fi
COPY pies_diag_setup.diff .
RUN patch -p1 < pies_diag_setup.diff
RUN ./bootstrap --skip-po
RUN ./configure --prefix=${PREFIX}\
          --sysconfdir=${PREFIX}/conf\
	  --disable-sysvinit\
	  --disable-nls\
	  FALLBACK_LOG=/proc/1/fd/2 \
	  DEFAULT_INCLUDE_PATH=${PREFIX}/conf\
	  DEFAULT_PREPROCESSOR="/pies/bin/xenv -s" &&\
    make INFO_DEPS= && \
    make INFO_DEPS= install DESTDIR=/install && \
    rm -rf ${PREFIX}/share/locale/
WORKDIR /usr/src
RUN git clone http://git.gnu.org.ua/xenv.git
WORKDIR /usr/src/xenv
RUN if [ -n "${XENV_TAG}" ]; then git checkout ${XENV_TAG}; fi
RUN make PREFIX=${PREFIX} LEXFLAGS= install-bin DESTDIR=/install

ARG OSVERSION=latest
FROM alpine:${OSVERSION}
ARG VERSION=
ARG PIES_TAG=
ARG XENV_TAG=
ENV DEBIAN_FRONTEND=noninteractive
COPY --from=builder /install /
ARG PREFIX=/pies
WORKDIR ${PREFIX}
RUN mkdir ${PREFIX}/conf ${PREFIX}/conf.d
COPY pies.conf ${PREFIX}/conf
COPY rc ${PREFIX}/conf
ENV PATH="/pies/sbin:/pies/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENTRYPOINT ["/pies/conf/rc"]
EXPOSE 8073
ARG VERSION
ARG CREATEDTIME
ARG PIES_VERSION
ARG XENV_VERSION
LABEL org.opencontainers.image.title="GNU Pies docker image" \
      org.opencontainers.image.documentation="Base for creating images with components managed by GNU Pies" \
      org.opencontainers.version="${VERSION}" \
      org.opencontainers.image.authors="Sergey Poznyakoff <gray@gnu.org>" \
      org.opencontainers.image.url="https://github.com/graygnuorg/docker-pies" \
      org.opencontainers.image.source="https://github.com/graygnuorg/docker-pies" \
      org.opencontainers.vendor="Sergey Poznyakoff" \
      org.opencontainers.image.licenses="GPLv3+" \
      org.opencontainers.image.description="pies ${PIES_VERSION}, xenv ${XENV_VERSION}" \
      org.opencontainers.image.created="${CREATEDTIME}"


