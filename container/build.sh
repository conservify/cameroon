#!/bin/bash

set -xe

whoami

ls -alh

pushd yocto/poky

ls -alh

source oe-init-build-env build-wifx

# time bitbake cameroon-ucla

time bitbake wifx-base

ls -alh

pwd

IMAGES=`pwd`/tmp/deploy/images

ROOTFS=`find . -name rootfs`

for rpm in `find tmp/work/cortexa5hf-neon-poky-linux-gnueabi -name "*cameroon*.rpm"`; do
	echo $rpm
	cp $rpm $IMAGES
done

for dir in `find tmp/work/cortexa5hf-neon-poky-linux-gnueabi -name "*cameroon*" -type d`; do
	find $dir
done

if [ -z "$ROOTFS" ]; then
	echo "missing rootfs"
else
	rsync -ua ${ROOTFS}/ ${IMAGES}/rootfs/

	pushd $ROOTFS

	pwd

	rm -f ${IMAGES}/rootfs.tar.bz2

	tar cpjf ${IMAGES}/rootfs.tar.bz2 .

	popd
fi

popd

echo Done!
