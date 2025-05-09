#!/usr/bin/env bash

INOTIFYWAIT_SCRIPT="${INOTIFYWAIT_SCRIPT:-"/inotifywait.sh"}"

INOTIFY_TARGET="${INOTIFY_TARGET:-}"
INOTIFY_SCRIPT="${INOTIFY_SCRIPT:-}"

if [ -z "${INOTIFY_TARGET+x}" ]; then
    echo "no target declared. exiting." >&2
    exit 1
fi
if [ -z "${INOTIFY_SCRIPT+x}" ]; then
    echo "no script declared. exiting." >&2
    exit 1
fi

if [ "$1" = "inotify-script" ]; then
    chmod +x "${INOTIFY_SCRIPT}"
    echo "[$(date -Iseconds)] inotify_proxy watching ${INOTIFY_TARGET}"
    inotify-proxy "${INOTIFY_TARGET}" > program.out 2>&1 &
    echo "[$(date -Iseconds)] running ${INOTIFYWAIT_SCRIPT}"
    exec "${INOTIFYWAIT_SCRIPT}" "${INOTIFY_TARGET}" "${INOTIFY_SCRIPT}"
else
    exec "${@}"
fi
