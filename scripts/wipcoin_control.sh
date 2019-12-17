#!/bin/bash


command=$1
id=1
idstring=$(printf '%03d' ${id})
while [ -f "/etc/systemd/system/wipcoin-${idstring}.service" ]; do
  echo "wipcoin-${idstring}:"
  systemctl $1 wipcoin-${idstring}.service
  id=$((id + 1))
  idstring=$(printf '%03d' ${id})
done
