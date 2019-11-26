#!/bin/bash

sudo -i -u postgres psql <<EOF
CREATE USER lora WITH ENCRYPTED PASSWORD 'asdfasdf';

CREATE DATABASE lora OWNER lora;

GRANT ALL PRIVILEGES ON DATABASE lora TO lora;
EOF

sudo -i -u postgres psql <<EOF
\c lora
CREATE EXTENSION hstore;
EOF

for file in schema/*.sql; do
	sudo -E -u postgres psql "postgresql://lora:asdfasdf@127.0.0.1/lora" < $file
done
