#!/bin/bash

set -xe

pushd yocto/poky

pwd

set +x
source oe-init-build-env
set -x

sed -i 's/BB_NO_NETWORK = "0"/BB_NO_NETWORK = "1"/' conf/local.conf

time bitbake core-image-base

pwd

ls -alh

IMAGES=`pwd`/tmp/deploy/images
ROOTFS=`pwd`/tmp/work/*/*/*/rootfs/

echo $ROOTFS

cp -ar conf ${IMAGES}

popd

echo done!
