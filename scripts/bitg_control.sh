#!/bin/bash

command=$1
id=1
idstring=$(printf '%03d' ${id})
while [ -f "/etc/systemd/system/bitg-${idstring}.service" ]; do
  echo "bitg-${idstring}:"
  systemctl $1 bitg-${idstring}.service
  id=$((id + 1))
  idstring=$(printf '%03d' ${id})
done
