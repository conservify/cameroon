#!/bin/bash

set -xe

pushd yocto/poky

pwd

set +x
source oe-init-build-env build-wifx
set -x

sed -i 's/BB_NO_NETWORK = "0"/BB_NO_NETWORK = "1"/' conf/local.conf

cp /home/worker/yocto/meta-wifx/recipes-bsp/u-boot/u-boot-at91_2017.03.bb tmp/deploy/images

time bitbake wifx-base

pwd

ls -alh

IMAGES=`pwd`/tmp/deploy/images
ROOTFS=`pwd`/tmp/work/*/*/*/rootfs/

for rpm in `find tmp/work/cortexa5hf-neon-poky-linux-gnueabi -name "*cameroon*.rpm"`; do
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

echo done!
