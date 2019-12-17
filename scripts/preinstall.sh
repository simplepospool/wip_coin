#!/bin/bash

COIN='bitgreen'
TICKER='bitg'

echo "####### Upgrading machine versions"
apt update && apt upgrade -y >/dev/null 2>&1
echo "####### installinging additional dependencies and docker if needed"
if ! apt-get install -y docker.io apt-transport-https curl fail2ban unattended-upgrades ufw dnsutils jq >/dev/null; then
  echo "Install cannot be completed successfully see errors above!"
fi

# Create swapfile if less then 2GB memory
totalmem=$(free -m | awk '/^Mem:/{print $2}')
totalswp=$(free -m | awk '/^Swap:/{print $2}')
totalm=$(($totalmem + $totalswp))
if [ $totalm -lt 4000 ]; then
  echo "Server memory is less then 2GB..."
  if ! grep -q '/swapfile' /etc/fstab; then
    echo "Creating a 2GB swapfile..."
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >>/etc/fstab
  fi
fi

#####################
echo "####### Creating the docker mount directories..."
mkdir -p /mnt/$TICKER/ /opt/$TICKER/

echo "####### Adding $TICKER control directories to path"
if [[ $(cat ~/.bashrc | grep $TICKER | wc -l) -eq 0 ]]; then
  echo 'export PATH=$PATH:/opt/$TICKER' >>~/.bashrc
fi
source ~/.bashrc

docker login registry.gitlab.com -u bitg-pub -p fzxLG9DGzhznyWxkJ6oB >/dev/null 2>&1

## Download the real scripts here
wget https://gitlab.com/bitgreen/bitg-docker/raw/master/scripts/install_bitg.sh -O /opt/$TICKER/install_bitg.sh
wget https://gitlab.com/bitgreen/bitg-docker/raw/master/scripts/multi_install_bitg.sh -O /opt/$TICKER/multi_install_bitg.sh
wget https://gitlab.com/bitgreen/bitg-docker/raw/master/scripts/bitg_control.sh -O /opt/$TICKER/bitg_control.sh
wget https://gitlab.com/bitgreen/bitg-docker/raw/master/scripts/bitg_all_params.sh -O /opt/$TICKER/bitg_all_params.sh
wget https://gitlab.com/bitgreen/bitg-docker/raw/master/scripts/uninstall_bitg.sh -O /opt/$TICKER/uninstall_bitg.sh
wget https://gitlab.com/bitgreen/bitg-docker/raw/master/scripts/bitg_mn_status.sh -O /opt/$TICKER/bitg_mn_status.sh
wget https://gitlab.com/bitgreen/bitg-docker/raw/master/scripts/bitg-cli.sh -O /opt/$TICKER/bitg-cli.sh
wget https://gitlab.com/bitgreen/bitg-docker/raw/master/scripts/bitg_repair.sh -O /opt/$TICKER/bitg_repair.sh
chmod +x /opt/$TICKER/*.sh

echo
echo "####### SERVER INSTALLED COPY AND PASTE THE FOLLOWING COMMAND TO INSTALL YOUR FIRST NODE"
echo "source ~/.bashrc && install_$TICKER.sh"
