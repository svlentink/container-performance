#!/bin/bash -e

DIR=`pwd`

create_images() {
  local conttype=$1
#  create_$conttype"_img" cli bash
  create_$conttype"_img" cli node
#  create_$conttype"_img" cli python
#  create_$conttype"_img" server lamp
}

create_docker_img() {
  local reqtype=$1
  local framework=$2
  docker build -t $reqtype-$framework $DIR/$framework/
}

create_lxc_img() {
  local reqtype=$1
  local framework=$2
  lxc-create -t alpine -n $reqtype"-"$framework
  cp $DIR/$framework/install.sh /var/lib/lxc/$reqtype"-"$framework/rootfs/
  lxc-start --name $reqtype"-"$framework
  lxc-attach --name $reqtype"-"$framework -- /install.sh
  lxc-stop --name $reqtype"-"$framework
#  echo "lxc.init_cmd = /entrypoint" >> /var/lib/lxc/$reqtype"-"$framework/config
}

create_rkt_img() {
  echo todo
}

create_openvz_img() {
  echo todo
}

if [ -z "$1" ]; then
  echo Please specify which containertype
  exit 1
fi

create_images $1
