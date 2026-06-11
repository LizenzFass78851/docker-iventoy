FROM debian:trixie-slim AS main

ARG DEBIAN_FRONTEND=noninteractive

FROM main AS downloader

ARG DEBIAN_FRONTEND
ARG IVENTOY_VERSION="1.0.35"

RUN apt update && apt dist-upgrade -yy && \
    apt install curl -yy && \
    apt-get autoremove -yy && \
    rm -rf /var/cache/apt /var/lib/apt/lists

RUN case "$(uname -m)" in \
      x86_64)  ARCH="x86_64"; EDITION="free"  ;; \
      aarch64) ARCH="arm64";  EDITION="trial" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac && \
    echo "Downloading iVentoy version ${IVENTOY_VERSION} for architecture ${ARCH} (${EDITION})..." && \
    curl -fSL "https://github.com/ventoy/PXE/releases/download/v${IVENTOY_VERSION}/iventoy-${IVENTOY_VERSION}-linux-${ARCH}-${EDITION}.tar.gz" \
    -o /tmp/iventoy.tar.gz

RUN tar -xvzf /tmp/iventoy.tar.gz -C / && \
    mv /iventoy-${IVENTOY_VERSION} /iventoy

FROM main

ARG DEBIAN_FRONTEND

ENV IVENTOY_API_ALL=1

RUN apt update && apt dist-upgrade -yy && \
    apt install --no-install-recommends supervisor curl -yy && \
    apt-get autoremove -yy && \
    rm -rf /var/cache/apt /var/lib/apt/lists

COPY --from=downloader /iventoy /iventoy

COPY files/supervisord.conf /etc/supervisor/supervisord.conf
COPY --chmod=0755 docker-entrypoint.sh /docker-entrypoint.sh

VOLUME /iventoy/iso /iventoy/data /iventoy/log /iventoy/user

RUN ln -sf /proc/1/fd/1 /iventoy/log/log.txt

WORKDIR /iventoy

RUN bash -c 'cp -ra ./data{,.orig}'

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -fs http://localhost:26000/ >/dev/null || exit 1

EXPOSE 26000 16000 10809 69/udp 67-68/udp
ENTRYPOINT ["/docker-entrypoint.sh"]
