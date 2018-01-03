#!/bin/bash

# JUST AN EXAMPLE, FEEL FREE TO CUSTOMIZE.

APP_NAME=NAME
VERSION=${1:-0.0.1}
ARCH=amd64

CNAME=${APP_NAME}-jessie-builder

mkdir -p build
lxc launch jessie-dhvenv-build-base $CNAME --ephemeral

# https://github.com/lxc/lxd/issues/3804#issuecomment-329998197
# Method described in the comment doesn't seem to work
echo -n "waiting for network to start"
while :; do
  lxc exec $CNAME -- ifconfig | grep "inet addr:10" && break
  sleep 1
  echo -n "."
done

echo "done!"

set -xe

lxc exec $CNAME -- mkdir -p /app
tar --exclude=./.git -czf - . | lxc file push - $CNAME/app/app.tar.gz
lxc exec $CNAME -- tar -C /app -xvzf /app/app.tar.gz
lxc exec $CNAME -- rm /app/app.tar.gz
lxc exec $CNAME -- apt-get update
lxc exec $CNAME -- /bin/bash -c "cd /app && mk-build-deps -ri -t 'apt-get -y"
lxc exec $CNAME -- /bin/bash -c "cd /app && dpkg-buildpackage -us -uc -b"

lxc file pull $CNAME/${APP_NAME}_${VERSION}_${ARCH}.changes build
lxc file pull $CNAME/${APP_NAME}_${VERSION}_${ARCH}.deb build
lxc stop $CNAME
