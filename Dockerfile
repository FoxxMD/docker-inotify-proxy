FROM debian:12.10

RUN apt update && apt install inotify-tools -y

COPY scripts/ /
COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "inotify-script" ]