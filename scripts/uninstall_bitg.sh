#!/bin/bash

COIN='bitgreen'
TICKER='bitg'


set -e

if [ $# -lt 1 ]; then
  echo 1>&2 "$0: Supply the node id to uninstall!"
  exit 2
fi

id=$(printf '%03d' "${1}")

systemctl disable "$TICKER-${id}"
systemctl stop "$TICKER-${id}"
rm -r "/mnt/$TICKER/${id}"
rm "/etc/systemd/system/$TICKER-${id}.service"