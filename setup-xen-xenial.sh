#!/bin/bash

# Run this script as root on a xenial VM created with Xen
# It fixes DNS and adds a specified sudo user for SSH login.


# Make sure only root can run script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Only continue if exactly 2 arguments
if [ "$#" -ne 2 ]; then
    echo "Need exactly 2 arguments: username and password (for SSH login)."
    exit 2
fi

username=$1
password=$2

cat /etc/resolvconf/resolv.conf.d/original > /etc/resolvconf/resolv.conf.d/base
resolvconf -u
adduser --disabled-password --gecos "" $username
echo $username + ":" + $password | sudo chpasswd