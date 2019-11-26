#!/bin/bash

sudo -i -u postgres psql <<EOF
DROP DATABASE lora;
DROP USER lora;
EOF
