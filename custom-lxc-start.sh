# this script servers as an alternative to lxc-execute, but is not used in our final research
CONTAINER_NAME=$1; shift
lxc-start --name $CONTAINER_NAME
lxc-attach --me $CONTAINER_NAME -- /entrypoint $@
lxc-stop --name $CONTAINER_NAME
