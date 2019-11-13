#!/bin/bash

sudo -u postgres psql <<EOF

DROP DATABASE IF EXISTS "lora";
DROP USER IF EXISTS "lora";

CREATE USER lora WITH ENCRYPTED PASSWORD 'asdfasdf';

CREATE DATABASE "lora" WITH OWNER = "lora";

GRANT ALL PRIVILEGES ON DATABASE "lora" TO "lora";

EOF

sudo -u postgres psql lora < schema/*.sql
