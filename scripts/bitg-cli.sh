#!/bin/bash

id=1
idstring=$(printf '%03d' ${id})
while [ -f "/etc/systemd/system/bitg-${idstring}.service" ]; do
  echo "bitg-${idstring}:"
  bitgreen-cli-${idstring} "$@"
  id=$((id + 1))
  idstring=$(printf '%03d' ${id})
done