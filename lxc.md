# LXC documentation

## LXC or LXD?
LXD provides a REST API to drive LXC containers. The API connects to libxlc, the LXC software library. LXD, which is written in Go, creates a system daemon that apps can access locally using a Unix socket, or over the network via HTTPS. So with LXD you are in fact using LXC because it is built on top of it. 

Source:https://stgraber.org/2016/03/11/lxd-2-0-introduction-to-lxd-112

For this project we chose to use LXD because it uses LXC anyway and it is more user friendly, allowing us to set up the environment faster. **When we talk about "LXC" throughout the project, this actually means we are using LXC by using LXD.**

## Important for comparison
LXC is designed for hosting virtual environments that “will typically be long running and based on a clean distribution image,” whereas “Docker focuses on ephemeral, stateless, minimal containers that won’t typically get upgraded or re-configured but instead just be replaced entirely.” If LXC's performance results are not so good as the other container technologies we tested, then this *could* be the reason.

Source: https://www.sumologic.com/blog/code/lxc-lxd-explaining-linux-containers

## Setting up VM with LXC

**Server: Setting up Xen VM to run LXC on:**

```shell
sudo xen-create-image --hostname=ls-lxc1 --dist=zesty --vcpus=2 --ip=145.100.109.25
sudo xl create /etc/xen/ls-lxc1.cfg

```

**VM:**

```shell
apt-get install git lxd lxc

```

## Launch lxc alphine image and get shell

```shell

sudo lxc launch images:alpine/3.6 alphine1
sudo lxc exec alphine1 sh

```

Source: https://wiki.alpinelinux.org/wiki/Install_Alpine_on_LXD