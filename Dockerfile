FROM debian:12.10

ENV INOTIFY_PROXY_VERSION=2.1.1

RUN apt update && \
    apt install --no-install-recommends -y \
    inotify-tools \
    rsync \
    ca-certificates \
    curl && \
    apt-get autoclean && \
    apt-get autoremove && \
      rm -rf \
        /config/.cache \
        /root/cache \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*

RUN cd /tmp && \
    curl -L https://github.com/cmuench/inotify-proxy/releases/download/${INOTIFY_PROXY_VERSION}/inotify-proxy_${INOTIFY_PROXY_VERSION}_linux_amd64.tar.gz -o proxy.tar.gz && \
    tar -xzvf proxy.tar.gz && \
    chmod +x inotify-proxy && \
    cp inotify-proxy /usr/bin/inotify-proxy

COPY scripts/ /
COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "inotify-script" ]