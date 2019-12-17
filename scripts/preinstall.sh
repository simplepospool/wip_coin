
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
mkdir -p /mnt/wipcoin/ /opt/wipcoin/

echo "####### Adding wipcoin control directories to path"
if [[ $(cat ~/.bashrc | grep wipcoin | wc -l) -eq 0 ]]; then
  echo 'export PATH=$PATH:/opt/wipcoin' >>~/.bashrc
fi
source ~/.bashrc

# docker login registry.gitlab.com -u simplepospool -p vhR1UmjVMcVpqPQRHxwY >/dev/null 2>&1

## Download the real scripts here
wget -qN https://raw.githubusercontent.com/simplepospool/wip_coin/master/scripts/install_wipcoin.sh -O /opt/wipcoin/install_wipcoin2.sh
wget -qN https://raw.githubusercontent.com/simplepospool/wip_coin/master/scripts/multi_install_wipcoin.sh -O /opt/wipcoin/multi_install_wipcoin.sh
wget -qN https://raw.githubusercontent.com/simplepospool/wip_coin/master/scripts/wipcoin_control.sh -O /opt/wipcoin/wipcoin_control.sh
wget -qN https://raw.githubusercontent.com/simplepospool/wip_coin/master/scripts/wipcoin_all_params.sh -O /opt/wipcoin/wipcoin_all_params.sh
wget -qN https://raw.githubusercontent.com/simplepospool/wip_coin/master/scripts/uninstall_wipcoin.sh -O /opt/wipcoin/uninstall_wipcoin.sh

chmod +x /opt/wipcoin/*.sh


echo
echo "####### SERVER INSTALLED COPY AND PASTE THE FOLLOWING COMMAND TO INSTALL YOUR FIRST NODE"
echo "source ~/.bashrc && install_wipcoin.sh"
