ARG OSVERSION=9
FROM debian:${OSVERSION}
ARG CODE_NAME=stretch
RUN apt-get -qq update && \
    apt-get -qq install apt-transport-https gnupg2 && \
    apt-key adv --keyserver keys.gnupg.net --recv-keys \
    3602B07F55D0C732 79FFD94BFCE230B1

RUN echo "deb [arch=amd64] https://debian.archive.norse.digital/${CODE_NAME} ${CODE_NAME} main" > /etc/apt/sources.list.d/norse.list && \
    apt-get -qq update && \
    apt-get install -y pies && \
    rm -rf /var/lib/apt/lists/*

COPY pies.conf /etc
RUN find /usr/share/pies -name pp-setup -delete
RUN mkdir /etc/pies.d /usr/share/pies/include
COPY pp-setup /usr/share/pies/include
ENTRYPOINT ["/usr/sbin/pies", "--foreground", "--stderr"]
EXPOSE 8073
    

