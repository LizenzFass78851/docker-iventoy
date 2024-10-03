FROM debian:bookworm-slim AS downloader

ENV DEBIAN_FRONTEND=noninteractive
ARG IVENTOY_VERSION=1.0.20

RUN apt update && apt dist-upgrade -yy && \
    apt install curl -yy && \
    apt-get autoremove -yy && \
    rm -rf /var/cache/apt /var/lib/apt/lists

RUN curl -kL https://github.com/ventoy/PXE/releases/download/v${IVENTOY_VERSION}/iventoy-${IVENTOY_VERSION}-linux-free.tar.gz -o /tmp/iventoy.tar.gz && \
    tar -xvzf /tmp/iventoy.tar.gz -C / && \
    mv /iventoy-${IVENTOY_VERSION} /iventoy

FROM debian:bookworm-slim
MAINTAINER gary@bowers1.com

ENV DEBIAN_FRONTEND=noninteractive

ENV IVENTOY_API_ALL=1
ENV IVENTOY_AUTO_RUN=1

RUN apt update && apt dist-upgrade -yy && \
    apt install --no-install-recommends supervisor netcat-openbsd \ 
    libevent-dev libglib2.0-dev libhivex-dev libc6-dev libwim-dev -yy && \
    apt-get autoremove -yy && \
    rm -rf /var/cache/apt /var/lib/apt/lists

COPY --from=downloader /iventoy /iventoy

COPY files/supervisord.conf /etc/supervisor/supervisord.conf
COPY docker-entrypoint.sh /docker-entrypoint.sh

VOLUME /iventoy/iso /iventoy/data /iventoy/log /iventoy/user

RUN ln -sf /proc/1/fd/1 /iventoy/log/log.txt

WORKDIR /iventoy

RUN cp -ra ./data ./data.orig

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD nc -z localhost 26000 || exit 1

EXPOSE 26000 16000 10809 69/udp 67-68/udp
ENTRYPOINT ["/docker-entrypoint.sh"]
