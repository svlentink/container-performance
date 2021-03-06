# LXC documentation

## LXC or LXD?
LXD provides a REST API to drive LXC containers. The API connects to libxlc, the LXC software library. LXD, which is written in Go, creates a system daemon that apps can access locally using a Unix socket, or over the network via HTTPS. So with LXD you are in fact using LXC because it is built on top of it. 

Source:https://stgraber.org/2016/03/11/lxd-2-0-introduction-to-lxd-112

For this project we chose to use LXD because it uses LXC anyway and it is more user friendly, allowing us to set up the environment faster. **When we talk about "LXC" throughout the project, this actually means we are using LXC by using LXD.**

## Important for comparison
LXC is designed for hosting virtual environments that “will typically be long running and based on a clean distribution image,” whereas “Docker focuses on ephemeral, stateless, minimal containers that won’t typically get upgraded or re-configured but instead just be replaced entirely.” If LXC's performance results are not so good as the other container technologies we tested, then this *could* be the reason.

Source: https://www.sumologic.com/blog/code/lxc-lxd-explaining-linux-containers

## Set up Xen VM with LXC on it

**Server:**

```shell
sudo xen-create-image --hostname=ls-xenial-lxc --memory=1024MB --size=5G --swap=1024MB --lvm=[OPTIONAL]<volumegroup> --dist=xenial --fs=ext3 --vcpus=2 --ip=<ip> --gateway=<gateway> --netmask=<netmask
sudo xl create /etc/xen/ls-lxc1.cfg

```

**VM:**

```shell
apt-get install git lxd lxc

```

## Launch lxc alpine image and get shell

```shell

sudo lxc launch images:alpine/3.6 alpine1
sudo lxc exec alpine1 sh

```

Source: https://wiki.alpinelinux.org/wiki/Install_Alpine_on_LXD


## lxc-execute

At first this seemed like the best solution,
however:
```shell
lxc-execute --name containername -- echo '#test' > /etc/cron.d/lxc-test
```

If we use an existing container (in which we install lxc, as mentioned [here](https://bugs.launchpad.net/ubuntu/+source/lxc/+bug/1171464))
or a non existing (random name),
both cases result in an effected host file system, which is certainly not what we want!
This is also mentioned [here](https://docs.oracle.com/cd/E37670_01/E37355/html/ol_app_containers.html)
at the bottom of the page as a note.

We now follow [this](https://unix.stackexchange.com/questions/102204/executing-a-command-inside-a-running-lxc)

Note that we now use it as a system container instead of a protected env. to execute. (should be mentioned in our final paper)

### but wait

It seemed that the in the command above, everything after `>` was on the host machine.
We confirmed that it does work, if we first run `apk add --no-cache lxc` inside the container.

```shell
lxc-execute -n cli-bash -- ls -al /tmp 2> /dev/null
```
