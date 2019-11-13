#!/bin/bash

set -e

echo BUILDING

whoami

pwd

ls -alh

pushd yocto/poky

source oe-init-build-env build-wifx

pwd

ls -alh

nice -n19 bitbake wifx-base

popd
