#!/bin/bash -e

DIR='.'

docker build -t cli-bash    -f $DIR/bash.Dockerfile .
docker build -t cli-node    -f $DIR/node.Dockerfile .
docker build -t cli-python  -f $DIR/python.Dockerfile .
docker build -t server-lamp -f $DIR/lamp.Dockerfile .

create_lxc_img() {
  local reqtype=$1
  local framework=$2
  lxc-create -t alpine -n $reqtype"-"$framework
  cp $DIR/install_$framework.sh /var/lib/lxc/$reqtype"-"$framework/rootfs/
  lxc-start --name $reqtype"-"$framework
  lxc-attach --name $reqtype"-"$framework -- /install_$framework.sh
  lxc-stop --name $reqtype"-"$framework
TODO the next step does not work yet
  echo "lxc.init_cmd = /entrypoint" >> /var/lib/lxc/$reqtype"-"$framework/config
}
create_lxc_img cli bash
create_lxc_img cli node
create_lxc_img cli python
create_lxc_img server lamp
