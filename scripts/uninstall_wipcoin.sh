#!/bin/bash

set -e

if [ $# -lt 1 ]; then
  echo 1>&2 "$0: Supply the node id to uninstall!"
  exit 2
fi

id=$(printf '%03d' "${1}")

systemctl disable "wipcoin-${id}"
systemctl stop "wipcoin-${id}"
rm -r "/mnt/wipcoin/${id}"
rm "/etc/systemd/system/wipcoin-${id}.service"
