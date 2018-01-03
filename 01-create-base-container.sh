#!/bin/bash

set -xe

CNAME=jessie-dhvenv-build-base

lxc delete $CNAME --force || true
lxc launch images:debian/jessie $CNAME
echo "wait until network is available..."
# https://github.com/lxc/lxd/issues/3804#issuecomment-329998197
# Method described in the comment doesn't seem to work
while :; do
  lxc exec $CNAME -- ifconfig | grep "inet addr:10" && break
  sleep 1
done

lxc file push setup-base-container.sh $CNAME/setup-base-container.sh
lxc exec $CNAME -- /bin/bash /setup-base-container.sh
lxc exec $CNAME -- rm /setup-base-container.sh
lxc stop $CNAME
lxc publish $CNAME --alias $CNAME
