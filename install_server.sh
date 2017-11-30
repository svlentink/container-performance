#!/bin/bash -e

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

# if no is provided, get system
[[ -z "$CONTAINERTYPE" ]] \
  && CONTAINERTYPE=$1
[[ -z "$CONTAINERTYPE" ]] \
  && read -p "Please specify what you want to install (docker,rkt or lxc)"  CONTAINERTYPE \
  && export "CONTAINERTYPE=$CONTAINERTYPE"
[[ -z "$CONTAINERTYPE" ]] \
  && echo No valid input \
  && exit 1

install_controller() {
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
}

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

GITHUB_REPO='containers/build'
LATEST_RELEASE_TAG=$(curl -Is https://github.com/${GITHUB_REPO}/releases/latest \
  | grep Location | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
wget -O /tmp/toinstall.tgz \
  https://github.com/${GITHUB_REPO}/releases/download/v$LATEST_RELEASE_TAG/acbuild-v$LATEST_RELEASE_TAG.tar.gz
tar xvfz /tmp/toinstall.tgz --directory /root/
ln -s  /root/acbuild-v*/* /usr/local/bin/ # make all the acbuild tools available to PATH
}

install_lxc() {
echo Installing LXC
# https://help.ubuntu.com/lts/serverguide/lxc.html
apt install -y lxc lxd
ln -s ~/container-performance/custom-lxc-start.sh /usr/local/bin/custom-lxc-start
}

install_openvz() {
echo OpenVZ is not used in this research
exit 1
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

install_controller

if [[ $CONTAINERTYPE == "docker" \
  || $CONTAINERTYPE == "rkt" \
  || $CONTAINERTYPE == "lxc" ]]; then
  install_$CONTAINERTYPE
  echo Installation completed successful
  ~/container-performance/images/create_images.sh $CONTAINERTYPE
  echo "rebooting in 3"
  sleep 1
  echo 2
  sleep 1
  echo 1
  sleep 1
  reboot
else
  echo Unknow containertype
  exit 1
fi
