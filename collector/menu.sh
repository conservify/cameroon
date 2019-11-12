#!/bin/bash

# nohup /home/pi/collector/menu.sh > /var/log/menu.log 2>&1 &

sudo ip addr add 192.168.1.100/24 dev eth0

pushd /home/pi/collector

while /bin/true; do
	source config.env
	./collector.py --source "$SOURCE_URL" --destiny "$DESTINY_URL"
	sleep 1
done

popd
