#!/usr/bin/env bash
set -euo pipefail

NET=ansible-lab
IMAGE=ansible-node:22.04

docker network inspect "$NET" >/dev/null 2>&1 || docker network create "$NET" >/dev/null

start_node() {
  local name="$1" ssh_port="$2"; shift 2
  if docker ps -a --format '{{.Names}}' | grep -qx "$name"; then
    docker start "$name" >/dev/null
  else
    docker run -d --name "$name" --hostname "$name" --network "$NET" \
      --privileged --cgroupns=host \
      -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
      --tmpfs /run --tmpfs /run/lock \
      -p "127.0.0.1:${ssh_port}:22" "$@" "$IMAGE" >/dev/null
  fi
  echo "started $name (ssh on 127.0.0.1:${ssh_port})"
}

start_node web1 2221 -p 127.0.0.1:8081:80
start_node web2 2222 -p 127.0.0.1:8082:80
start_node db1  2223
