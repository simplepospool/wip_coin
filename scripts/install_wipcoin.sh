#!/bin/bash

IMAGE="simplepospool/wipcoin:latest"

set -e

## GET IPv4/6 Address
IP=$(curl -s ipinfo.io/ip)
echo "####### Your IP: $IP"

## check for nodes now
# Get current wipcoin node number
id=1
idstring=$(printf '%03d' ${id})
while [ -f "/etc/systemd/system/wipcoin-${idstring}.service" ]; do
  id=$((id + 1))
  idstring=$(printf '%03d' ${id})
done
rpcport=1${idstring}
port=2${idstring}

echo "####### creating /etc/systemd/system/wipcoin-${idstring}.service"
# IMAGE="simplepospool/wipcoin:2.0"
cat <<EOF >/etc/systemd/system/wipcoin-${idstring}.service
[Unit]
Description=WIPC Daemon Container ${idstring}
After=docker.service
Requires=docker.service

[Service]
TimeoutStartSec=10m
Restart=always
ExecStartPre=-/usr/bin/docker stop wipcoin-${idstring}
ExecStartPre=-/usr/bin/docker rm  wipcoin-${idstring}
# Always pull the latest docker image
ExecStartPre=/usr/bin/docker pull ${IMAGE}
ExecStop=/usr/bin/docker exec wipcoin-${idstring} /opt/app/wipcoin-cli stop
ExecStart=/usr/bin/docker run --rm -p ${port}:${port} -p ${rpcport}:${rpcport} -v /mnt/wipcoin/${idstring}:/root/.wipcoin --name wipcoin-${idstring} ${IMAGE}
[Install]
WantedBy=multi-user.target
EOF
systemctl enable wipcoin-${idstring}.service
systemctl daemon-reload

echo "####### creating /mnt/wipcoin/${idstring}/wipcoin.conf"
mkdir -p /mnt/wipcoin/${idstring}
cat <<EOF >/mnt/wipcoin/${idstring}/wipcoin.conf
rpcuser=user
rpcpassword=asdd3rascsar
rpcport=${rpcport}
rpcallowip=127.0.0.1
server=1
# Docker doesn't run as daemon
daemon=0
listen=1
txindex=1
logtimestamps=1
#
port=${port}
externalip=${IP}

EOF

systemctl start wipcoin-${idstring}

echo "####### adding control scripts"
cat <<EOF >/opt/wipcoin/wipcoin-cli-${idstring}
#!/bin/bash
docker exec wipcoin-${idstring} /opt/app/wipcoin-cli \$@
EOF
chmod +x /opt/wipcoin/wipcoin-cli-${idstring}

cat <<EOF >/opt/wipcoin/chainparams-${idstring}.sh
#!/bin/bash
echo
echo "### YOUR PARAMETERS!"
cat /mnt/wipcoin/${idstring}/bls.json |  jq '. += {"ip":"'"${IP}:${port}"'", "node":"wipcoin-'"${idstring}"'"}'
EOF
chmod +x /opt/wipcoin/chainparams-${idstring}.sh

count=1
until wipcoin-cli-${idstring} masternode status 2> /dev/null; do
  echo "##### Waiting for start. Your parameters will appear shortly (1-2 mins)! (looping $count)"
  sleep 10
  count=$((count + 1))
  if [ $count -gt 30 ]; then
    echo "##### Server seems overloaded cannot get chainparams try again later with 'sh /opt/wipcoin/chainparams-${idstring}.sh'"
    break
  fi
done
sleep 5


sh /opt/wipcoin/chainparams-${idstring}.sh


echo "#--# type 'source ~/.bashrc' after that you can use the wipcoin-cli-${idstring} i.E. 'wipcoin-cli-${idstring} masternode status'"
