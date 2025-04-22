# docker-inotify-proxy

[Dockerhub Image `foxxmd/inotify-proxy`](https://hub.docker.com/r/foxxmd/inotify-proxy)

**The poor man's unidirectional file syncing**

This image is mostly based on [docker-inotify](https://github.com/devodev/docker-inotify) but with [`inotify-proxy`](https://github.com/cmuench/inotify-proxy) to enable usage with NFS docker volumes.

Usage is exactly the same as docker-inotify with these differences:

* Image is debian based instead of alpine
* Includes `rsync` and `curl` in image
* Watches `INOTIFY_TARGET` with `inotify-proxy` as well as inotifywait (so should really only be used for NFS volumes)

# Why?

I needed a **very** simple method to keep read-only, occasionally-accessed data from a docker [NFS volume mount](https://docs.docker.com/engine/storage/volumes/#create-a-service-which-creates-an-nfs-volume) available to multiple containers, even if the NFS host was unavailable.

The solution was this image which can be used to:

* Create a service next to the target container
  * Mount the NFS volume into this container
  * Watch for changes in NFS folder/volume
  * On change copy/`rsync` the contents to a *local* bind mount
* Use the local bind mount in the target container to make data available to the service

As an example compose stack:

```yaml
services:
  # uses ./synced local folder
  targetService:
    image: traefik:v3.3
    # ...
    volumes:
     - ./synced:/etc/traefik/dynamicConfig:ro

  # syncs traefikConfig folder from remote NFS mount to ./synced on host
  inotify:
    image: foxxmd/inotify-proxy:latest
    volumes:
      - type: volume
        source: appdata
        target: /data
        read_only: true
        volume:
          subpath: traefikConfig
      - ./synced:/sync:rw
    environment:
      - INOTIFY_TARGET=/data
      - INOTIFY_SCRIPT=/trigger.sh
      - INOTIFY_QUIET=false
      - INOTIFY_CFG_QUIET=false
      - INOTIFY_CFG_EVENTS=modify attrib delete delete_self
    configs:
      - source: trigger.sh
        target: /trigger.sh

volumes:
  appdata:
    driver_opts:
      type: "nfs"
      o: "vers=4.2,addr=192.168.1.100,nolock,soft"
      device: ":/my/nfs/mount"

configs:
  trigger.sh:
    content: |
      #!/bin/sh
      rsync -avz /data/ /sync --delete
```

This ensure that even if the NFS host goes down that the local folder still exists with the last known good data and can be accessed by the target container.

## Should I use this?

Probably not. It will work in a pinch but it's not for production use.