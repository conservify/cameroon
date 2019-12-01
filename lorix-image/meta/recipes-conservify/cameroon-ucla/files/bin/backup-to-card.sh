#!/bin/bash

mount /dev/mmcblk0 /tmp/card

/opt/conservify/bin/sd-maintainer --delete --size 1000000 --database "postgres://chirpstack_as_data:asdfasdf@127.0.0.1/chirpstack_as_data?sslmode=disable" --archive /tmp/card

umount /tmp/card
