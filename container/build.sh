#!/bin/bash

set -e

echo BUILDING

pwd
whoami

ls -alh

pushd yocto/poky

source oe-init-build-env build-wifx

ls -alh

nice -n19 bitbake wifx-base

popd
