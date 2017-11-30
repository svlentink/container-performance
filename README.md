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

Use `docker`,`rkt` or `lxc` as CONTAINERTYPE.
```shell
export CONTAINERTYPE=insert_here
curl -sSL https://raw.githubusercontent.com/svlentink/container-performance/master/install_server.sh | bash
```
