#!/bin/bash -ex

# This script is used to install one of the environments
# make sure you only install one environment,
# since multiple could interfere with each other

[[ -f /etc/debian_version ]] \
  || ( echo FAIL This script is made for a debian based OS && exit 1 )

# Make sure only root can run script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

[[ -z "$1" ]] \
  && echo "Please specify what you want to install (docker,rkt,openvz or lxc)" \
  && exit 1

echo installing basics for admin and the custon controller
apt update
apt install -y \
  tree \
  vim \
  wget \
  curl \
  tmux \
  man \
  python3 \
  python-setuptools \
  python-dev \
  git
easy_install pip

cd ~
if [ ! -d container-performance ]; then
  echo fetching the custom controller
  git clone https://github.com/svlentink/container-performance.git
else
  echo "custom controller (git repo) already fetched. continue..."
fi

echo installing python dependencies
pip install -r ~/container-performance/controller/requirements.txt

install_docker() {
echo Installing docker
# http://get.docker.com
curl -sSL get.docker.com | sh
usermod -aG docker $USER
}

install_rkt() {
echo Installing rkt
# https://coreos.com/rkt/docs/latest/distributions.html#deb-based
gpg --recv-key 18AD5014C99EF7E3BA5F6CE950BDD3E0FC8A365E
wget https://github.com/rkt/rkt/releases/download/v1.29.0/rkt_1.29.0-1_amd64.deb
wget https://github.com/rkt/rkt/releases/download/v1.29.0/rkt_1.29.0-1_amd64.deb.asc
gpg --verify rkt_1.29.0-1_amd64.deb.asc
sudo dpkg -i rkt_1.29.0-1_amd64.deb
}

install_lxc() {
echo Installing LXC
# https://help.ubuntu.com/lts/serverguide/lxc.html
apt install -y lxc lxd
}

install_openvz() {
echo Installing OpenVZ
# https://linoxide.com/ubuntu-how-to/install-configure-openvz-ubuntu-14-04-15-04/
echo " deb http://download.openvz.org/debian wheezy main" > /etc/apt/sources.list.d/openvz-rhel6.list
wget -O /tmp/openvz.key http://ftp.openvz.org/debian/archive.key
apt-key add /tmp/openvz.key
apt update
apt install -y linux-image-openvz-amd64
cat << EOF >> /etc/sysctl.conf
net.ipv4.ip_forward = 1
net.ipv6.conf.default.forwarding = 1
net.ipv6.conf.all.forwarding = 1
net.ipv4.conf.default.proxy_arp = 0
net.ipv4.conf.all.rp_filter = 1
kernel.sysrq = 1
net.ipv4.conf.default.send_redirects = 1
net.ipv4.conf.all.send_redirects = 0
EOF
sysctl -p
apt install -y vzctl vzquota ploop
wget -O /tmp/vzstats_0.3.2-1_all.deb http://repo.coolcold.org/pool/main/v/vzstats/vzstats_0.3.2-1_all.deb
sudo dpkg -i /tmp/vzstats_0.3.2-1_all.deb 
echo Make sure to boot the machine with the openvz kernel
}

install_$1
echo "Installation completed sucessful, rebooting in 3"
sleep 1
echo 2
sleep 1
echo 1
sleep 1
reboot
