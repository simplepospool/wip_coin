#!/bin/bash

COIN='bitgreen'
TICKER='bitg'
PORT='9'
RPCPORT='10'
IMAGE='registry.gitlab.com/bitgreen/bitg-docker:latest'


set -e

## GET IPv4/6 Address
IP=$(curl -s ipinfo.io/ip)
echo "####### Your IP: $IP"

## check for nodes now
# Get current bitg node number
id=1
idstring=$(printf '%03d' ${id})
while [ -f "/etc/systemd/system/$TICKER-${idstring}.service" ]; do
  id=$((id + 1))
  idstring=$(printf '%03d' ${id})
done
port=$PORT${idstring}
rpcport=$RPCPORT${idstring}

echo "####### creating /etc/systemd/system/$TICKER-${idstring}.service"

cat <<EOF >/etc/systemd/system/$TICKER-${idstring}.service
[Unit]
Description=$TICKER Daemon Container ${idstring}
After=docker.service
Requires=docker.service

[Service]
TimeoutStartSec=10m
Restart=always
ExecStartPre=-/usr/bin/docker stop $TICKER-${idstring}
ExecStartPre=-/usr/bin/docker rm  $TICKER-${idstring}
# Always pull the latest docker image
ExecStartPre=/usr/bin/docker pull ${IMAGE}
ExecStop=/usr/bin/docker exec $TICKER-${idstring} /opt/app/$COIN-cli stop
ExecStart=/usr/bin/docker run --rm -p ${port}:${port} -p ${rpcport}:${rpcport} -v /mnt/$TICKER/${idstring}:/root/.$COIN --name $TICKER-${idstring} ${IMAGE}
[Install]
WantedBy=multi-user.target
EOF
systemctl enable $TICKER-${idstring}.service
systemctl daemon-reload

echo "####### creating /mnt/$TICKER/${idstring}/$COIN.conf"
mkdir -p /mnt/$TICKER/${idstring}
cat <<EOF >/mnt/$TICKER/${idstring}/$COIN.conf
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

addnode=45.63.2.241
addnode=104.156.249.186
addnode=140.82.12.18
addnode=149.28.239.44
addnode=149.28.61.99
EOF

systemctl start $TICKER-${idstring}

echo "####### adding control scripts"
cat <<EOF >/opt/$TICKER/$COIN-cli-${idstring}
#!/bin/bash
docker exec $TICKER-${idstring} /opt/app/$COIN-cli \$@
EOF
chmod +x /opt/$TICKER/$COIN-cli-${idstring}

cat <<EOF >/opt/$TICKER/chainparams-${idstring}.sh
#!/bin/bash
echo
echo "### YOUR PARAMETERS!"
cat /mnt/$TICKER/${idstring}/bls.json |  jq '. += {"ip":"${IP}:${port}", "node":"$(hostname)-$TICKER-${idstring}"}'
EOF
chmod +x /opt/$TICKER/chainparams-${idstring}.sh

count=1
until $COIN-cli-${idstring} masternode status 2> /dev/null; do
  echo "##### Waiting for start. Your parameters will appear shortly (1-2 mins)! (looping $count)"
  sleep 10
  count=$((count + 1))
  if [ $count -gt 30 ]; then
    echo "##### Server seems overloaded cannot get chainparams try again later with 'sh /opt/$TICKER/chainparams-${idstring}.sh'"
    break
  fi
done
sleep 5

sh /opt/$TICKER/chainparams-${idstring}.sh

echo "#--# type 'source ~/.bashrc' after that you can use the $COIN-cli-${idstring} i.E. '$COIN-cli-${idstring} masternode status'"
