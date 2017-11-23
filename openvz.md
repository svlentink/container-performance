# OpenVZ documentation


## Set up Xen VM with OpenVZ on it

**Server: Setting up Xen VM to run LXC on:**

```shell
sudo xen-create-image --hostname=ls-xenial-openvz --memory=1024MB --size=5G --swap=1024MB --lvm=[OPTIONAL]<volumegroup> --dist=xenial --fs=ext3 --vcpus=2 --ip=<ip> --gateway=<gateway> --netmask=<netmask>
sudo xl create /etc/xen/ls-openvz1.cfg

```