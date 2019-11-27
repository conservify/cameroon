CREATE USER chirpstack_as WITH ENCRYPTED PASSWORD 'password';
CREATE DATABASE chirpstack_as OWNER chirpstack_as;
GRANT ALL PRIVILEGES ON DATABASE chirpstack_as TO chirpstack_as;

CREATE USER chirpstack_ns WITH ENCRYPTED PASSWORD 'password';
CREATE DATABASE chirpstack_ns OWNER chirpstack_ns;
GRANT ALL PRIVILEGES ON DATABASE chirpstack_ns TO chirpstack_ns;

CREATE USER chirpstack_as_data WITH ENCRYPTED PASSWORD 'password';
CREATE DATABASE chirpstack_as_data OWNER chirpstack_as_data;
GRANT ALL PRIVILEGES ON DATABASE chirpstack_as_data TO chirpstack_as_data;

\c chirpstack_as
CREATE EXTENSION hstore;
CREATE EXTENSION pg_trgm;

\c chirpstack_as_data
CREATE EXTENSION hstore;
CREATE EXTENSION pg_trgm;

\c chirpstack_ns
CREATE EXTENSION hstore;
CREATE EXTENSION pg_trgm;
