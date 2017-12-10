# container-performance
Real time container utilization performance comparison

## Purpose

This is a research project for the course Large Systems at os3.nl (MSc SNE).

The documentation will follow afterward.

## Request definition

A request could mean several things.
We could describe a request as the loading of a website,
which could include multiple sources (e.g. html, css, js).
This would mean we keep our container 'alive' for a pre-defined time,
to facilite multiple HTTP requests, which serve a single web page request.

## Installation

We used Ubuntu Xenial VPS with 4GB of ram.

Use `docker`,`rkt` or `lxc` as CONTAINERTYPE.
```shell
sudo su
export CONTAINERTYPE=insert_here
curl -sSL https://raw.githubusercontent.com/svlentink/container-performance/master/install_server.sh | bash
```


And after the reboot you can run:
```shell
sudo su
export CONTAINERTYPE=insert_here
/root/container-performance/controller/main.py & \
  sleep 3 && /root/container-performance/controller/gather-metrics.py
```

But you should first manually check if memcached is working (`netstat -tulpn`)
and perform all the request manually for its output
`curl main-controller:8081/GET/<server,cli>/<lamp,bash,node,python>/<lxc,docker>/123`

## Rkt

We only used the default `rkt` way,
future research could include `rkt fly`,
which still is in [development](https://coreos.com/rkt/docs/latest/subcommands/fly.html).
