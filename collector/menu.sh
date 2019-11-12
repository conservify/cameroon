#!/bin/bash

# NOTE: change shebang to run with bash
# nohup /home/pi/collector/menu.sh |& tee /var/log/menu.log |& logger &

sudo ip addr add 192.168.1.100/24 dev eth0

pushd /home/pi/collector

while /bin/true; do
	source config.env
	./collector.py --source "$SOURCE_URL" --destiny "$DESTINY_URL" --watch "$WATCH"
	sleep 1
done

popd
