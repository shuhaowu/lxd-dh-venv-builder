#!/bin/bash

set -xe

DH_VIRTUALENV_SHA=b7101f62fa78435f52953b5d40b99f58376b3436

export DEBIAN_FRONTEND=noninteractive
echo "deb http://ftp.debian.org/debian jessie-backports main" > /etc/apt/sources.list.d/jessie-backports.list
apt-get update
apt-get install -y wget zip devscripts python-virtualenv
# This stuff should really be in build-depends but since we need jessie-backports..
apt-get install -t jessie-backports -y python-sphinx-rtd-theme python-sphinx

cd ~
wget -O dh-virtualenv.zip https://github.com/spotify/dh-virtualenv/archive/${DH_VIRTUALENV_SHA}.zip
unzip dh-virtualenv.zip

cd dh-virtualenv-${DH_VIRTUALENV_SHA}
mk-build-deps -ri -t "apt-get -y"
dpkg-buildpackage -us -uc -b

cd ..
dpkg -i dh-virtualenv_*.deb

rm dh-virtualenv* -rf
apt-get purge -y python-sphinx-rtd-theme python-sphinx
apt-get autoremove --purge -y
apt-get clean
