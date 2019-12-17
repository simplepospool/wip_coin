#!/bin/bash


id=1
idstring=$(printf '%03d' ${id})
JSON="[]"
while [ -f "/etc/systemd/system/wipcoin-${idstring}.service" ]; do
  NEW=$(sh /opt/wipcoin/chainparams-${idstring}.sh)
  JSON=$(echo $JSON | jq '. += ['"$NEW"']')

  id=$((id + 1))
  idstring=$(printf '%03d' ${id})
done

echo "$JSON" | jq .
