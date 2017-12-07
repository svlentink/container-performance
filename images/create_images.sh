#!/bin/bash -e

DIR=~/container-performance/images

echo Entering $0

create_images() {
  local conttype=$1
  create_$conttype"_img" cli bash
  create_$conttype"_img" cli node
  create_$conttype"_img" cli python
  create_$conttype"_img" server lamp
}

create_docker_img() {
  local reqtype=$1
  local framework=$2
  docker build -t $reqtype-$framework $DIR/$framework/
  [[ $reqtype == "server" ]] && SERVEROPTIONS="-p 80:80 --net=host"
  docker run -d $SERVEROPTIONS --name $reqtype-$framework $reqtype-$framework
  docker stop $reqtype-$framework
}

create_lxc_img() {
  local reqtype=$1
  local framework=$2
  lxc-create -t alpine -n $reqtype"-"$framework
  cp $DIR/$framework/install.sh /var/lib/lxc/$reqtype"-"$framework/rootfs/
  lxc-start --name $reqtype"-"$framework
  sleep 6 # if this was not provide, apk could not fetch the sources list

  # to enable lxc-execute, we need lxc installed in the container
  [[ $reqtype == "cli" ]] && lxc-attach -n $reqtype"-"$framework -- apk add --no-cache lxc

  lxc-attach --name $reqtype"-"$framework -- /install.sh
  lxc-stop --name $reqtype"-"$framework
#  echo "lxc.init_cmd = /entrypoint" >> /var/lib/lxc/$reqtype"-"$framework/config
}

create_rkt_img() {
  echo todo
}


if [ -z "$1" ]; then
  echo Please specify which containertype
  exit 1
fi

create_images $1
