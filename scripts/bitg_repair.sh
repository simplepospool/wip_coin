#!/bin/bash
set -e

if [ $# -lt 1 ]; then
  echo 1>&2 "$0: Supply the node id to repair!"
  exit 2
fi

id=$(printf '%03d' "${1}")

systemctl stop "bitg-${id}"

# Create a temporary directory and store its name in a variable ...
TMPDIR=$(mktemp -d)

# Bail out if the temp directory wasn't created successfully.
if [ ! -e $TMPDIR ]; then
    >&2 echo "Failed to create temp directory"
    exit 1
fi

# Make sure it gets removed even if the script exits abnormally.
trap "exit 1"           HUP INT PIPE QUIT TERM
trap 'rm -rf "$TMPDIR"' EXIT

mv "/mnt/bitg/${id}/bitgreen.conf" "/mnt/bitg/${id}/bls.json" "$TMPDIR/"
rm -rf "/mnt/bitg/${id}/*"
mv $TMPDIR/* "/mnt/bitg/${id}/"

systemctl start "bitg-${id}"
echo "Repaired your node check the logs with:"
echo "journalctl -fu bitg-${id}"
