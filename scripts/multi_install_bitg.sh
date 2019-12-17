#!/bin/bash

if [ $# -lt 1 ]; then
  echo 1>&2 "$0: Supply number of nodes to setup!"
  exit 2
fi

NUM=$1
for i in $(seq 1 $1); do
  /opt/bitg/install_bitg.sh
done


