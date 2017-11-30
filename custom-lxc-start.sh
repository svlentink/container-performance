
CONTAINER_NAME=$1; shift
lxc-start --name $CONTAINER_NAME
lxc-attach --name $CONTAINER_NAME -- /entrypoint $@
lxc-stop --name $CONTAINER_NAME
