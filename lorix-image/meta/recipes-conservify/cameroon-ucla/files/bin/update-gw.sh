#!/bin/bash

set -e

GATEWAY_EUI_NIC="eth0"
GATEWAY_EUI=$(ip link show $GATEWAY_EUI_NIC | awk '/ether/ {print $2}' | awk -F\: '{print $1$2$3"FFFE"$4$5$6}')
GATEWAY_EUI=${GATEWAY_EUI^^}

sudo -u postgres psql chirpstack_as -c "UPDATE gateway SET mac = '\x$GATEWAY_EUI' WHERE mac = '\\x0000000000088888';"
sudo -u postgres psql chirpstack_ns -c "UPDATE gateway SET gateway_id = '\x$GATEWAY_EUI' WHERE gateway_id = '\\x0000000000088888';"
