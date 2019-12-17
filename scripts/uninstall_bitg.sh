#!/bin/bash
set -e

if [ $# -lt 1 ]; then
  echo 1>&2 "$0: Supply the node id to uninstall!"
  exit 2
fi

id=$(printf '%03d' "${1}")

systemctl disable "bitg-${id}"
systemctl stop "bitg-${id}"
rm -r "/mnt/bitg/${id}"
rm "/etc/systemd/system/bitg-${id}.service"