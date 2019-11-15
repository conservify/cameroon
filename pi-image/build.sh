#!/bin/bash

set -xe

pushd yocto/poky

pwd

source oe-init-build-env

cp -ar conf tmp/deploy/images

time bitbake rpi-basic-image

pwd

ls -alh

IMAGES=`pwd`/tmp/deploy/images

cp -ar conf ${IMAGES}

popd

echo done!
