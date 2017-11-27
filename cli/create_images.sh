#!/bin/sh -e

docker build -t cli-bash -f bash.Dockerfile .
docker build -t cli-node -f node.Dockerfile .
docker build -t cli-python -f python.Dockerfile .
