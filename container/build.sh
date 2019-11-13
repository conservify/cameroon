#!/bin/bash

set -xe

whoami

ls -alh

pushd yocto/poky

source oe-init-build-env build-wifx

ls -alh

time nice -n19 bitbake wifx-base

find . -type d

IMAGES=`pwd`/tmp/deploy/images

ROOTFS=`find . -name rootfs`

pushd $ROOTFS

rm -f ${IMAGES}/rootfs.tar.bz2

tar cpjf ${IMAGES}/rootfs.tar.bz2 .

popd

popd

echo Done!
