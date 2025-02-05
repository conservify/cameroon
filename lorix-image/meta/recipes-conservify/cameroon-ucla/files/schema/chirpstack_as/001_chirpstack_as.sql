--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.0
-- Dumped by pg_dump version 9.5.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;
SET default_tablespace = '';
SET default_with_oids = false;

--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner:
--

-- CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner:
--

-- COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner:
--

-- CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner:
--

-- COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: application; Type: TABLE; Schema: public; Owner: chirpstack_as
--

CREATE TABLE public.application (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    description text NOT NULL,
    organization_id bigint NOT NULL,
    service_profile_id uuid NOT NULL,
    payload_codec text DEFAULT ''::text NOT NULL,
    payload_encoder_script text DEFAULT ''::text NOT NULL,
    payload_decoder_script text DEFAULT ''::text NOT NULL
);


ALTER TABLE public.application OWNER TO chirpstack_as;

--
-- Name: application_id_seq; Type: SEQUENCE; Schema: public; Owner: chirpstack_as
--

CREATE SEQUENCE public.application_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.application_id_seq OWNER TO chirpstack_as;

--
-- Name: application_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chirpstack_as
--

ALTER SEQUENCE public.application_id_seq OWNED BY public.application.id;


--
-- Name: code_migration; Type: TABLE; Schema: public; Owner: chirpstack_as
--

CREATE TABLE public.code_migration (
    id text NOT NULL,
    applied_at timestamp with time zone NOT NULL
);


ALTER TABLE public.code_migration OWNER TO chirpstack_as;

--
-- Name: device; Type: TABLE; Schema: public; Owner: chirpstack_as
--

CREATE TABLE public.device (
    dev_eui bytea NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    application_id bigint NOT NULL,
    device_profile_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    description text NOT NULL,
    last_seen_at timestamp with time zone,
    device_status_battery numeric(5,2),
    device_status_margin integer,
    latitude double precision,
    longitude double precision,
    altitude double precision,
    device_status_external_power_source boolean NOT NULL,
    dr smallint,
    variables public.hstore,
    tags public.hstore
);


ALTER TABLE public.device OWNER TO chirpstack_as;

--
-- Name: device_activation; Type: TABLE; Schema: public; Owner: chirpstack_as
--

CREATE TABLE public.device_activation (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    dev_eui bytea NOT NULL,
    dev_addr bytea NOT NULL,
    app_s_key bytea NOT NULL
);


ALTER TABLE public.device_activation OWNER TO chirpstack_as;

--
-- Name: device_activation_id_seq; Type: SEQUENCE; Schema: public; Owner: chirpstack_as
--

CREATE SEQUENCE public.device_activation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.device_activation_id_seq OWNER TO chirpstack_as;

--
-- Name: device_activation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chirpstack_as
--

ALTER SEQUENCE public.device_activation_id_seq OWNED BY public.device_activation.id;


--
-- Name: device_keys; Type: TABLE; Schema: public; Owner: chirpstack_as
--

CREATE TABLE public.device_keys (
    dev_eui bytea NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    nwk_key bytea NOT NULL,
    join_nonce integer NOT NULL,
    app_key bytea NOT NULL,
    gen_app_key bytea NOT NULL
);


ALTER TABLE public.device_keys OWNER TO chirpstack_as;

--
-- Name: device_multicast_group; Type: TABLE; Schema: public; Owner: chirpstack_as
--

CREATE TABLE public.device_multicast_group (
    dev_eui bytea NOT NULL,
    multicast_group_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL
);


ALTER TABLE public.device_multicast_group OWNER TO chirpstack_as;

--
-- Name: device_profile; Type: TABLE; Schema: public; Owner: chirpstack_as
--

CREATE TABLE public.device_profile (
    device_profile_id uuid NOT NULL,
    network_server_id bigint NOT NULL,
    organization_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name character varying(100) NOT NULL,
    payload_codec text NOT NULL,
    payload_encoder_script text NOT NULL,
    payload_decoder_script text NOT NULL
);


ALTER TABLE public.device_profile OWNER TO chirpstack_as;

--
-- Name: fuota_deployment; Type: TABLE; Schema: public; Owner: chirpstack_as
--

CREATE TABLE public.fuota_deployment (
    id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name character varying(100) NOT NULL,
    multicast_group_id uuid,
    group_type character(1) NOT NULL,
    dr smallint NOT NULL,
    frequency integer NOT NULL,
    ping_slot_period smallint NOT NULL,
    fragmentation_matrix bytea NOT NULL,
    descriptor bytea NOT NULL,
    payload bytea NOT NULL,
    frag_size smallint NOT NULL,
    redundancy smallint NOT NULL,
    multicast_timeout smallint NOT NULL,
    block_ack_delay smallint NOT NULL,
    state character varying(20) NOT NULL,
    unicast_timeout bigint NOT NULL,
    next_step_after timestamp with time zone NOT NULL
);


ALTER TABLE public.fuota_deployment OWNER TO chirpstack_as;

--
-- Name: fuota_deployment_device; Type: TABLE; Schema: public; Owner: chirpstack_as
--

CREATE TABLE public.fuota_deployment_device (
    fuota_deployment_id uuid NOT NULL,
    dev_eui bytea NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    state character varying(20) NOT NULL,
    error_message text NOT NULL
);


ALTER TABLE public.fuota_deployment_device OWNER TO chirpstack_as;

--
-- Name: gateway; Type: TABLE; Schema: public; Owner: chirpstack_as
--

CREATE TABLE public.gateway (
    mac bytea NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name character varying(100) NOT NULL,
    description text NOT NULL,
    organization_id bigint NOT NULL,
    ping boolean DEFAULT false NOT NULL,
    last_ping_id bigint,
    last_ping_sent_at timestamp with time zone,
    network_server_id bigint NOT NULL,
    gateway_profile_id uuid,
    first_seen_at timestamp with time zone,
    last_seen_at timestamp with time zone,
    latitude double precision NOT NULL,
    longitude double precision NOT NULL,
    altitude double precision NOT NULL
);


ALTER TABLE public.gateway OWNER TO chirpstack_as;

--
-- Name: gateway_ping; Type: TABLE; Schema: public; Owner: chirpstack_as
--

CREATE TABLE public.gateway_ping (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    gateway_mac bytea NOT NULL,
    frequency integer NOT NULL,
    dr integer NOT NULL
);


ALTER TABLE public.gateway_ping OWNER TO chirpstack_as;

--
-- Name: gateway_ping_id_seq; Type: SEQUENCE; Schema: public; Owner: chirpstack_as
--

CREATE SEQUENCE public.gateway_ping_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.gateway_ping_id_seq OWNER TO chirpstack_as;

--
-- Name: gateway_ping_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chirpstack_as
--

ALTER SEQUENCE public.gateway_ping_id_seq OWNED BY public.gateway_ping.id;


--
-- Name: gateway_ping_rx; Type: TABLE; Schema: public; Owner: chirpstack_as
--

CREATE TABLE public.gateway_ping_rx (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    ping_id bigint NOT NULL,
    gateway_mac bytea NOT NULL,
    received_at timestamp with time zone,
    rssi integer NOT NULL,
    lora_snr numeric(3,1) NOT NULL,
    location point,
    altitude double precision
);


ALTER TABLE public.gateway_ping_rx OWNER TO chirpstack_as;

--
-- Name: gateway_ping_rx_id_seq; Type: SEQUENCE; Schema: public; Owner: chirpstack_as
--

CREATE SEQUENCE public.gateway_ping_rx_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.gateway_ping_rx_id_seq OWNER TO chirpstack_as;

--
-- Name: gateway_ping_rx_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chirpstack_as
--

ALTER SEQUENCE public.gateway_ping_rx_id_seq OWNED BY public.gateway_ping_rx.id;


--
-- Name: gateway_profile; Type: TABLE; Schema: public; Owner: chirpstack_as
--

CREATE TABLE public.gateway_profile (
    gateway_profile_id uuid NOT NULL,
    network_server_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.gateway_profile OWNER TO chirpstack_as;

--
-- Name: gorp_migrations; Type: TABLE; Schema: public; Owner: chirpstack_as
--

CREATE TABLE public.gorp_migrations (
    id text NOT NULL,
    applied_at timestamp with time zone
);


ALTER TABLE public.gorp_migrations OWNER TO chirpstack_as;

--
-- Name: integration; Type: TABLE; Schema: public; Owner: chirpstack_as
--

CREATE TABLE public.integration (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    application_id bigint NOT NULL,
    kind character varying(20) NOT NULL,
    settings jsonb
);


ALTER TABLE public.integration OWNER TO chirpstack_as;

--
-- Name: integration_id_seq; Type: SEQUENCE; Schema: public; Owner: chirpstack_as
--

CREATE SEQUENCE public.integration_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.integration_id_seq OWNER TO chirpstack_as;

--
-- Name: integration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chirpstack_as
--

ALTER SEQUENCE public.integration_id_seq OWNED BY public.integration.id;


--
-- Name: multicast_group; Type: TABLE; Schema: public; Owner: chirpstack_as
--

CREATE TABLE public.multicast_group (
    id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name character varying(100) NOT NULL,
    service_profile_id uuid NOT NULL,
    mc_app_s_key bytea,
    mc_key bytea NOT NULL
);


ALTER TABLE public.multicast_group OWNER TO chirpstack_as;

--
-- Name: network_server; Type: TABLE; Schema: public; Owner: chirpstack_as
--

CREATE TABLE public.network_server (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name character varying(100) NOT NULL,
    server character varying(255) NOT NULL,
    ca_cert text DEFAULT ''::text NOT NULL,
    tls_cert text DEFAULT ''::text NOT NULL,
    tls_key text DEFAULT ''::text NOT NULL,
    routing_profile_ca_cert text DEFAULT ''::text NOT NULL,
    routing_profile_tls_cert text DEFAULT ''::text NOT NULL,
    routing_profile_tls_key text DEFAULT ''::text NOT NULL,
    gateway_discovery_enabled boolean DEFAULT false NOT NULL,
    gateway_discovery_interval integer DEFAULT 0 NOT NULL,
    gateway_discovery_tx_frequency integer DEFAULT 0 NOT NULL,
    gateway_discovery_dr smallint DEFAULT 0 NOT NULL
);


ALTER TABLE public.network_server OWNER TO chirpstack_as;

--
-- Name: network_server_id_seq; Type: SEQUENCE; Schema: public; Owner: chirpstack_as
--

CREATE SEQUENCE public.network_server_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.network_server_id_seq OWNER TO chirpstack_as;

--
-- Name: network_server_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chirpstack_as
--

ALTER SEQUENCE public.network_server_id_seq OWNED BY public.network_server.id;


--
-- Name: organization; Type: TABLE; Schema: public; Owner: chirpstack_as
--

CREATE TABLE public.organization (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name character varying(100) NOT NULL,
    display_name character varying(100) NOT NULL,
    can_have_gateways boolean NOT NULL
);


ALTER TABLE public.organization OWNER TO chirpstack_as;

--
-- Name: organization_id_seq; Type: SEQUENCE; Schema: public; Owner: chirpstack_as
--

CREATE SEQUENCE public.organization_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.organization_id_seq OWNER TO chirpstack_as;

--
-- Name: organization_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chirpstack_as
--

ALTER SEQUENCE public.organization_id_seq OWNED BY public.organization.id;


--
-- Name: organization_user; Type: TABLE; Schema: public; Owner: chirpstack_as
--

CREATE TABLE public.organization_user (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    user_id bigint NOT NULL,
    organization_id bigint NOT NULL,
    is_admin boolean NOT NULL,
    is_device_admin boolean NOT NULL,
    is_gateway_admin boolean NOT NULL
);


ALTER TABLE public.organization_user OWNER TO chirpstack_as;

--
-- Name: organization_user_id_seq; Type: SEQUENCE; Schema: public; Owner: chirpstack_as
--

CREATE SEQUENCE public.organization_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.organization_user_id_seq OWNER TO chirpstack_as;

--
-- Name: organization_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chirpstack_as
--

ALTER SEQUENCE public.organization_user_id_seq OWNED BY public.organization_user.id;


--
-- Name: remote_fragmentation_session; Type: TABLE; Schema: public; Owner: chirpstack_as
--

CREATE TABLE public.remote_fragmentation_session (
    dev_eui bytea NOT NULL,
    frag_index smallint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    mc_group_ids smallint[],
    nb_frag integer NOT NULL,
    frag_size smallint NOT NULL,
    fragmentation_matrix bytea NOT NULL,
    block_ack_delay smallint NOT NULL,
    padding smallint NOT NULL,
    descriptor bytea NOT NULL,
    state character varying(20) NOT NULL,
    state_provisioned boolean DEFAULT false NOT NULL,
    retry_after timestamp with time zone NOT NULL,
    retry_count smallint NOT NULL,
    retry_interval bigint NOT NULL
);


ALTER TABLE public.remote_fragmentation_session OWNER TO chirpstack_as;

--
-- Name: remote_multicast_class_c_session; Type: TABLE; Schema: public; Owner: chirpstack_as
--

CREATE TABLE public.remote_multicast_class_c_session (
    dev_eui bytea NOT NULL,
    multicast_group_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    mc_group_id smallint NOT NULL,
    session_time timestamp with time zone NOT NULL,
    session_time_out smallint NOT NULL,
    dl_frequency integer NOT NULL,
    dr smallint NOT NULL,
    state_provisioned boolean DEFAULT false NOT NULL,
    retry_after timestamp with time zone NOT NULL,
    retry_count smallint NOT NULL,
    retry_interval bigint NOT NULL
);


ALTER TABLE public.remote_multicast_class_c_session OWNER TO chirpstack_as;

--
-- Name: remote_multicast_setup; Type: TABLE; Schema: public; Owner: chirpstack_as
--

CREATE TABLE public.remote_multicast_setup (
    dev_eui bytea NOT NULL,
    multicast_group_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    mc_group_id smallint NOT NULL,
    mc_addr bytea NOT NULL,
    mc_key_encrypted bytea NOT NULL,
    min_mc_f_cnt bigint NOT NULL,
    max_mc_f_cnt bigint NOT NULL,
    state character varying(20) NOT NULL,
    state_provisioned boolean DEFAULT false NOT NULL,
    retry_after timestamp with time zone NOT NULL,
    retry_count smallint NOT NULL,
    retry_interval bigint NOT NULL
);


ALTER TABLE public.remote_multicast_setup OWNER TO chirpstack_as;

--
-- Name: service_profile; Type: TABLE; Schema: public; Owner: chirpstack_as
--

CREATE TABLE public.service_profile (
    service_profile_id uuid NOT NULL,
    organization_id bigint NOT NULL,
    network_server_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.service_profile OWNER TO chirpstack_as;

--
-- Name: user; Type: TABLE; Schema: public; Owner: chirpstack_as
--

CREATE TABLE public."user" (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    username character varying(100) NOT NULL,
    password_hash character varying(200) NOT NULL,
    session_ttl bigint NOT NULL,
    is_active boolean NOT NULL,
    is_admin boolean NOT NULL,
    email text DEFAULT ''::text NOT NULL,
    note text DEFAULT ''::text NOT NULL
);


ALTER TABLE public."user" OWNER TO chirpstack_as;

--
-- Name: user_id_seq; Type: SEQUENCE; Schema: public; Owner: chirpstack_as
--

CREATE SEQUENCE public.user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_id_seq OWNER TO chirpstack_as;

--
-- Name: user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chirpstack_as
--

ALTER SEQUENCE public.user_id_seq OWNED BY public."user".id;


--
-- Name: application id; Type: DEFAULT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.application ALTER COLUMN id SET DEFAULT nextval('public.application_id_seq'::regclass);


--
-- Name: device_activation id; Type: DEFAULT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.device_activation ALTER COLUMN id SET DEFAULT nextval('public.device_activation_id_seq'::regclass);


--
-- Name: gateway_ping id; Type: DEFAULT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.gateway_ping ALTER COLUMN id SET DEFAULT nextval('public.gateway_ping_id_seq'::regclass);


--
-- Name: gateway_ping_rx id; Type: DEFAULT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.gateway_ping_rx ALTER COLUMN id SET DEFAULT nextval('public.gateway_ping_rx_id_seq'::regclass);


--
-- Name: integration id; Type: DEFAULT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.integration ALTER COLUMN id SET DEFAULT nextval('public.integration_id_seq'::regclass);


--
-- Name: network_server id; Type: DEFAULT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.network_server ALTER COLUMN id SET DEFAULT nextval('public.network_server_id_seq'::regclass);


--
-- Name: organization id; Type: DEFAULT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.organization ALTER COLUMN id SET DEFAULT nextval('public.organization_id_seq'::regclass);


--
-- Name: organization_user id; Type: DEFAULT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.organization_user ALTER COLUMN id SET DEFAULT nextval('public.organization_user_id_seq'::regclass);


--
-- Name: user id; Type: DEFAULT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public."user" ALTER COLUMN id SET DEFAULT nextval('public.user_id_seq'::regclass);


--
-- Data for Name: application; Type: TABLE DATA; Schema: public; Owner: chirpstack_as
--

COPY public.application (id, name, description, organization_id, service_profile_id, payload_codec, payload_encoder_script, payload_decoder_script) FROM stdin;
1	app	app	1	a4d9d8ac-8b48-417b-843b-e68bc2e8baa0	CUSTOM_JS		\n// Decode decodes an array of bytes into an object.\n//  - fPort contains the LoRaWAN fPort number\n//  - bytes is an array of bytes, e.g. [225, 230, 255, 0]\n// The function must return an object, e.g. {"temperature": 22.5}\nfunction bin2String(array) {\n  return String.fromCharCode.apply(String, array);\n}\n\nfunction bin2HexStr(arr)\n \n{\n    var str = "";\n    for(var i=0; i<arr.length; i++)\n    {\n\n       var tmp = arr[i].toString(16);\n       if(tmp.length == 1)\n       {\n           tmp = "0" + tmp;\n       }\n       str += tmp;\n    }\n    return str;\n}\n\nfunction Decode(fPort, bytes) \n{\n  \tvar myObj = {"DecodeDataString":"", "DecodeDataHex":""};\n  \tvar tostring=bin2String(bytes);\n  \tvar tosHextring=bin2HexStr(bytes);\n  \tmyObj.DecodeDataString = tostring;\n  \tmyObj.DecodeDataHex = tosHextring;\n\treturn myObj;\n}
\.


--
-- Data for Name: code_migration; Type: TABLE DATA; Schema: public; Owner: chirpstack_as
--

COPY public.code_migration (id, applied_at) FROM stdin;
migrate_gw_stats	2019-11-08 02:38:11.214972+00
\.


--
-- Data for Name: device; Type: TABLE DATA; Schema: public; Owner: chirpstack_as
--

COPY public.device (dev_eui, created_at, updated_at, application_id, device_profile_id, name, description, last_seen_at, device_status_battery, device_status_margin, latitude, longitude, altitude, device_status_external_power_source, dr, variables, tags) FROM stdin;
\\x0000000000000555	2019-11-08 02:46:11.323242+00	2019-11-08 02:46:11.323242+00	1	9e89a1f2-fbbf-46fa-840d-73f238053bbd	device_otaa	device_otaa	\N	\N	\N	\N	\N	\N	f	\N	\N	\N
\\x0000000000000666	2019-11-08 02:48:03.579549+00	2019-11-08 02:48:03.579549+00	1	c1671da1-726a-4259-868a-e8472f0f8b59	device_abp	device_abp	\N	\N	\N	\N	\N	\N	f	\N	\N	\N
\.


--
-- Data for Name: device_activation; Type: TABLE DATA; Schema: public; Owner: chirpstack_as
--

COPY public.device_activation (id, created_at, dev_eui, dev_addr, app_s_key) FROM stdin;
1	2019-11-08 02:48:36.354602+00	\\x0000000000000666	\\x00000666	\\x00000000000000000000000000000666
\.


--
-- Data for Name: device_keys; Type: TABLE DATA; Schema: public; Owner: chirpstack_as
--

COPY public.device_keys (dev_eui, created_at, updated_at, nwk_key, join_nonce, app_key, gen_app_key) FROM stdin;
\\x0000000000000555	2019-11-08 02:46:33.696641+00	2019-11-08 02:46:33.696641+00	\\x00000000000000000000000000000555	0	\\x00000000000000000000000000000000	\\x00000000000000000000000000000555
\.


--
-- Data for Name: device_multicast_group; Type: TABLE DATA; Schema: public; Owner: chirpstack_as
--

COPY public.device_multicast_group (dev_eui, multicast_group_id, created_at) FROM stdin;
\.


--
-- Data for Name: device_profile; Type: TABLE DATA; Schema: public; Owner: chirpstack_as
--

COPY public.device_profile (device_profile_id, network_server_id, organization_id, created_at, updated_at, name, payload_codec, payload_encoder_script, payload_decoder_script) FROM stdin;
9e89a1f2-fbbf-46fa-840d-73f238053bbd	1	1	2019-11-08 02:41:21.626245+00	2019-11-08 02:45:31.466375+00	device_profile_otaa			\n// Decode decodes an array of bytes into an object.\n//  - fPort contains the LoRaWAN fPort number\n//  - bytes is an array of bytes, e.g. [225, 230, 255, 0]\n// The function must return an object, e.g. {"temperature": 22.5}\nfunction bin2String(array) {\n  return String.fromCharCode.apply(String, array);\n}\n\nfunction bin2HexStr(arr)\n \n{\n    var str = "";\n    for(var i=0; i<arr.length; i++)\n    {\n\n       var tmp = arr[i].toString(16);\n       if(tmp.length == 1)\n       {\n           tmp = "0" + tmp;\n       }\n       str += tmp;\n    }\n    return str;\n}\n\nfunction Decode(fPort, bytes) \n{\n  \tvar myObj = {"DecodeDataString":"", "DecodeDataHex":""};\n  \tvar tostring=bin2String(bytes);\n  \tvar tosHextring=bin2HexStr(bytes);\n  \tmyObj.DecodeDataString = tostring;\n  \tmyObj.DecodeDataHex = tosHextring;\n\treturn myObj;\n}
c1671da1-726a-4259-868a-e8472f0f8b59	1	1	2019-11-08 02:41:45.432903+00	2019-11-08 02:45:37.246008+00	device_profile_abp			\n// Decode decodes an array of bytes into an object.\n//  - fPort contains the LoRaWAN fPort number\n//  - bytes is an array of bytes, e.g. [225, 230, 255, 0]\n// The function must return an object, e.g. {"temperature": 22.5}\nfunction bin2String(array) {\n  return String.fromCharCode.apply(String, array);\n}\n\nfunction bin2HexStr(arr)\n \n{\n    var str = "";\n    for(var i=0; i<arr.length; i++)\n    {\n\n       var tmp = arr[i].toString(16);\n       if(tmp.length == 1)\n       {\n           tmp = "0" + tmp;\n       }\n       str += tmp;\n    }\n    return str;\n}\n\nfunction Decode(fPort, bytes) \n{\n  \tvar myObj = {"DecodeDataString":"", "DecodeDataHex":""};\n  \tvar tostring=bin2String(bytes);\n  \tvar tosHextring=bin2HexStr(bytes);\n  \tmyObj.DecodeDataString = tostring;\n  \tmyObj.DecodeDataHex = tosHextring;\n\treturn myObj;\n}
\.


--
-- Data for Name: fuota_deployment; Type: TABLE DATA; Schema: public; Owner: chirpstack_as
--

COPY public.fuota_deployment (id, created_at, updated_at, name, multicast_group_id, group_type, dr, frequency, ping_slot_period, fragmentation_matrix, descriptor, payload, frag_size, redundancy, multicast_timeout, block_ack_delay, state, unicast_timeout, next_step_after) FROM stdin;
\.


--
-- Data for Name: fuota_deployment_device; Type: TABLE DATA; Schema: public; Owner: chirpstack_as
--

COPY public.fuota_deployment_device (fuota_deployment_id, dev_eui, created_at, updated_at, state, error_message) FROM stdin;
\.


--
-- Data for Name: gateway; Type: TABLE DATA; Schema: public; Owner: chirpstack_as
--

COPY public.gateway (mac, created_at, updated_at, name, description, organization_id, ping, last_ping_id, last_ping_sent_at, network_server_id, gateway_profile_id, first_seen_at, last_seen_at, latitude, longitude, altitude) FROM stdin;
\\x0000000000088888	2019-11-08 02:44:34.341903+00	2019-11-08 02:44:34.341903+00	gateway	gateway	1	f	\N	\N	1	\N	\N	\N	0	0	0
\.


--
-- Data for Name: gateway_ping; Type: TABLE DATA; Schema: public; Owner: chirpstack_as
--

COPY public.gateway_ping (id, created_at, gateway_mac, frequency, dr) FROM stdin;
\.


--
-- Data for Name: gateway_ping_rx; Type: TABLE DATA; Schema: public; Owner: chirpstack_as
--

COPY public.gateway_ping_rx (id, created_at, ping_id, gateway_mac, received_at, rssi, lora_snr, location, altitude) FROM stdin;
\.


--
-- Data for Name: gateway_profile; Type: TABLE DATA; Schema: public; Owner: chirpstack_as
--

COPY public.gateway_profile (gateway_profile_id, network_server_id, created_at, updated_at, name) FROM stdin;
e381f69c-918e-4a91-bb33-b8f6ba22a64d	1	2019-11-08 02:39:54.124426+00	2019-11-08 02:39:54.124426+00	gateway_profile
\.


--
-- Data for Name: gorp_migrations; Type: TABLE DATA; Schema: public; Owner: chirpstack_as
--

COPY public.gorp_migrations (id, applied_at) FROM stdin;
0001_initial.sql	2019-11-08 02:38:08.648966+00
0002_join_accept_params.sql	2019-11-08 02:38:09.221887+00
0003_rx_window_and_rx2_dr.sql	2019-11-08 02:38:09.243486+00
0004_add_node_apps_nwks_key_name_devaddr.sql	2019-11-08 02:38:09.263977+00
0005_add_queue.sql	2019-11-08 02:38:09.400093+00
0006_remove_application_table.sql	2019-11-08 02:38:09.416322+00
0007_migrate_channels_to_channel_list.sql	2019-11-08 02:38:09.480325+00
0008_relax_fcnt.sql	2019-11-08 02:38:09.494729+00
0009_adr_interval_and_install_margin.sql	2019-11-08 02:38:09.506384+00
0010_recreate_application_table.sql	2019-11-08 02:38:09.621131+00
0011_node_description_and_is_abp.sql	2019-11-08 02:38:09.646524+00
0012_class_c_node.sql	2019-11-08 02:38:09.652324+00
0013_application_settings.sql	2019-11-08 02:38:09.672374+00
0014_users_and_application_users.sql	2019-11-08 02:38:09.728783+00
0015_organizations.sql	2019-11-08 02:38:09.810844+00
0016_delete_channel_list.sql	2019-11-08 02:38:09.821596+00
0017_integrations.sql	2019-11-08 02:38:09.851422+00
0018_gateway_ping.sql	2019-11-08 02:38:10.123927+00
0019_node_prefix_search.sql	2019-11-08 02:38:10.185576+00
0020_backend_interfaces.sql	2019-11-08 02:38:10.790023+00
0021_user_email_and_note.sql	2019-11-08 02:38:10.814852+00
0022_add_device_queue_mapping.sql	2019-11-08 02:38:10.838032+00
0023_payload_decoder.sql	2019-11-08 02:38:10.842588+00
0024_network_server_certs.sql	2019-11-08 02:38:10.853353+00
0025_device_status.sql	2019-11-08 02:38:10.857191+00
0026_network_server_gw_discovery.sql	2019-11-08 02:38:10.860978+00
0027_global_search.sql	2019-11-08 02:38:10.876853+00
0028_gateway_profile.sql	2019-11-08 02:38:10.910956+00
0029_cleanup_old_tables.sql	2019-11-08 02:38:10.930473+00
0030_lorawan_11_keys.sql	2019-11-08 02:38:10.944003+00
0031_cleanup_indices.sql	2019-11-08 02:38:10.952184+00
0032_fix_table_constraints.sql	2019-11-08 02:38:10.970226+00
0033_drop_device_queue_mapping.sql	2019-11-08 02:38:10.975189+00
0034_drop_nwk_session_keys.sql	2019-11-08 02:38:10.979222+00
0035_multicast.sql	2019-11-08 02:38:11.011778+00
0036_device_location.sql	2019-11-08 02:38:11.016936+00
0037_fix_device_status.sql	2019-11-08 02:38:11.04506+00
0038_device_profile_payload_codec.sql	2019-11-08 02:38:11.057708+00
0039_application_add_dr.sql	2019-11-08 02:38:11.060515+00
0040_fuota.sql	2019-11-08 02:38:11.171391+00
0041_device_variables.sql	2019-11-08 02:38:11.184953+00
0042_drop_multicast_f_cnt.sql	2019-11-08 02:38:11.188468+00
0043_extend_org_user_permissions.sql	2019-11-08 02:38:11.192375+00
0044_gateway_location_first_and_last_seen.sql	2019-11-08 02:38:11.197492+00
0045_code_migrations.sql	2019-11-08 02:38:11.210291+00
\.


--
-- Data for Name: integration; Type: TABLE DATA; Schema: public; Owner: chirpstack_as
--

COPY public.integration (id, created_at, updated_at, application_id, kind, settings) FROM stdin;
\.


--
-- Data for Name: multicast_group; Type: TABLE DATA; Schema: public; Owner: chirpstack_as
--

COPY public.multicast_group (id, created_at, updated_at, name, service_profile_id, mc_app_s_key, mc_key) FROM stdin;
\.


--
-- Data for Name: network_server; Type: TABLE DATA; Schema: public; Owner: chirpstack_as
--

COPY public.network_server (id, created_at, updated_at, name, server, ca_cert, tls_cert, tls_key, routing_profile_ca_cert, routing_profile_tls_cert, routing_profile_tls_key, gateway_discovery_enabled, gateway_discovery_interval, gateway_discovery_tx_frequency, gateway_discovery_dr) FROM stdin;
1	2019-11-08 02:39:13.771113+00	2019-11-08 02:39:13.771113+00	ns	127.0.0.1:8000							f	0	0	0
\.


--
-- Data for Name: organization; Type: TABLE DATA; Schema: public; Owner: chirpstack_as
--

COPY public.organization (id, created_at, updated_at, name, display_name, can_have_gateways) FROM stdin;
1	2019-11-08 02:38:09.733811+00	2019-11-08 02:38:09.733811+00	chirpstack	ChirpStack	t
\.


--
-- Data for Name: organization_user; Type: TABLE DATA; Schema: public; Owner: chirpstack_as
--

COPY public.organization_user (id, created_at, updated_at, user_id, organization_id, is_admin, is_device_admin, is_gateway_admin) FROM stdin;
1	2019-11-08 02:38:09.733811+00	2019-11-08 02:38:09.733811+00	1	1	t	f	f
\.


--
-- Data for Name: remote_fragmentation_session; Type: TABLE DATA; Schema: public; Owner: chirpstack_as
--

COPY public.remote_fragmentation_session (dev_eui, frag_index, created_at, updated_at, mc_group_ids, nb_frag, frag_size, fragmentation_matrix, block_ack_delay, padding, descriptor, state, state_provisioned, retry_after, retry_count, retry_interval) FROM stdin;
\.


--
-- Data for Name: remote_multicast_class_c_session; Type: TABLE DATA; Schema: public; Owner: chirpstack_as
--

COPY public.remote_multicast_class_c_session (dev_eui, multicast_group_id, created_at, updated_at, mc_group_id, session_time, session_time_out, dl_frequency, dr, state_provisioned, retry_after, retry_count, retry_interval) FROM stdin;
\.


--
-- Data for Name: remote_multicast_setup; Type: TABLE DATA; Schema: public; Owner: chirpstack_as
--

COPY public.remote_multicast_setup (dev_eui, multicast_group_id, created_at, updated_at, mc_group_id, mc_addr, mc_key_encrypted, min_mc_f_cnt, max_mc_f_cnt, state, state_provisioned, retry_after, retry_count, retry_interval) FROM stdin;
\.


--
-- Data for Name: service_profile; Type: TABLE DATA; Schema: public; Owner: chirpstack_as
--

COPY public.service_profile (service_profile_id, organization_id, network_server_id, created_at, updated_at, name) FROM stdin;
a4d9d8ac-8b48-417b-843b-e68bc2e8baa0	1	1	2019-11-08 02:40:32.453436+00	2019-11-08 02:40:32.453436+00	service-profile
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: chirpstack_as
--

COPY public."user" (id, created_at, updated_at, username, password_hash, session_ttl, is_active, is_admin, email, note) FROM stdin;
1	2019-11-08 02:38:09.678864+00	2019-11-08 02:38:09.678864+00	admin	PBKDF2$sha512$1$l8zGKtxRESq3PA2kFhHRWA==$H3lGMxOt55wjwoc+myeOoABofJY9oDpldJa7fhqdjbh700V6FLPML75UmBOt9J5VFNjAL1AvqCozA1HJM0QVGA==	0	t	t	jacob@conservify.org	
\.


--
-- Name: application_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chirpstack_as
--

SELECT pg_catalog.setval('public.application_id_seq', 1, true);


--
-- Name: device_activation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chirpstack_as
--

SELECT pg_catalog.setval('public.device_activation_id_seq', 1, true);


--
-- Name: gateway_ping_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chirpstack_as
--

SELECT pg_catalog.setval('public.gateway_ping_id_seq', 1, false);


--
-- Name: gateway_ping_rx_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chirpstack_as
--

SELECT pg_catalog.setval('public.gateway_ping_rx_id_seq', 1, false);


--
-- Name: integration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chirpstack_as
--

SELECT pg_catalog.setval('public.integration_id_seq', 1, false);


--
-- Name: network_server_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chirpstack_as
--

SELECT pg_catalog.setval('public.network_server_id_seq', 1, true);


--
-- Name: organization_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chirpstack_as
--

SELECT pg_catalog.setval('public.organization_id_seq', 1, true);


--
-- Name: organization_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chirpstack_as
--

SELECT pg_catalog.setval('public.organization_user_id_seq', 1, true);


--
-- Name: user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chirpstack_as
--

SELECT pg_catalog.setval('public.user_id_seq', 1, true);


--
-- Name: application application_name_organization_id_key; Type: CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.application
    ADD CONSTRAINT application_name_organization_id_key UNIQUE (name, organization_id);


--
-- Name: application application_pkey; Type: CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.application
    ADD CONSTRAINT application_pkey PRIMARY KEY (id);


--
-- Name: code_migration code_migration_pkey; Type: CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.code_migration
    ADD CONSTRAINT code_migration_pkey PRIMARY KEY (id);


--
-- Name: device_activation device_activation_pkey; Type: CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.device_activation
    ADD CONSTRAINT device_activation_pkey PRIMARY KEY (id);


--
-- Name: device_keys device_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.device_keys
    ADD CONSTRAINT device_keys_pkey PRIMARY KEY (dev_eui);


--
-- Name: device_multicast_group device_multicast_group_pkey; Type: CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.device_multicast_group
    ADD CONSTRAINT device_multicast_group_pkey PRIMARY KEY (multicast_group_id, dev_eui);


--
-- Name: device device_pkey; Type: CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.device
    ADD CONSTRAINT device_pkey PRIMARY KEY (dev_eui);


--
-- Name: device_profile device_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.device_profile
    ADD CONSTRAINT device_profile_pkey PRIMARY KEY (device_profile_id);


--
-- Name: fuota_deployment_device fuota_deployment_device_pkey; Type: CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.fuota_deployment_device
    ADD CONSTRAINT fuota_deployment_device_pkey PRIMARY KEY (fuota_deployment_id, dev_eui);


--
-- Name: fuota_deployment fuota_deployment_pkey; Type: CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.fuota_deployment
    ADD CONSTRAINT fuota_deployment_pkey PRIMARY KEY (id);


--
-- Name: gateway gateway_name_organization_id_key; Type: CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.gateway
    ADD CONSTRAINT gateway_name_organization_id_key UNIQUE (name, organization_id);


--
-- Name: gateway_ping gateway_ping_pkey; Type: CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.gateway_ping
    ADD CONSTRAINT gateway_ping_pkey PRIMARY KEY (id);


--
-- Name: gateway_ping_rx gateway_ping_rx_pkey; Type: CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.gateway_ping_rx
    ADD CONSTRAINT gateway_ping_rx_pkey PRIMARY KEY (id);


--
-- Name: gateway gateway_pkey; Type: CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.gateway
    ADD CONSTRAINT gateway_pkey PRIMARY KEY (mac);


--
-- Name: gateway_profile gateway_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.gateway_profile
    ADD CONSTRAINT gateway_profile_pkey PRIMARY KEY (gateway_profile_id);


--
-- Name: gorp_migrations gorp_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.gorp_migrations
    ADD CONSTRAINT gorp_migrations_pkey PRIMARY KEY (id);


--
-- Name: integration integration_kind_application_id; Type: CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.integration
    ADD CONSTRAINT integration_kind_application_id UNIQUE (kind, application_id);


--
-- Name: integration integration_pkey; Type: CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.integration
    ADD CONSTRAINT integration_pkey PRIMARY KEY (id);


--
-- Name: multicast_group multicast_group_pkey; Type: CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.multicast_group
    ADD CONSTRAINT multicast_group_pkey PRIMARY KEY (id);


--
-- Name: network_server network_server_pkey; Type: CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.network_server
    ADD CONSTRAINT network_server_pkey PRIMARY KEY (id);


--
-- Name: organization organization_pkey; Type: CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.organization
    ADD CONSTRAINT organization_pkey PRIMARY KEY (id);


--
-- Name: organization_user organization_user_pkey; Type: CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.organization_user
    ADD CONSTRAINT organization_user_pkey PRIMARY KEY (id);


--
-- Name: organization_user organization_user_user_id_organization_id_key; Type: CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.organization_user
    ADD CONSTRAINT organization_user_user_id_organization_id_key UNIQUE (user_id, organization_id);


--
-- Name: remote_fragmentation_session remote_fragmentation_session_pkey; Type: CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.remote_fragmentation_session
    ADD CONSTRAINT remote_fragmentation_session_pkey PRIMARY KEY (dev_eui, frag_index);


--
-- Name: remote_multicast_class_c_session remote_multicast_class_c_session_pkey; Type: CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.remote_multicast_class_c_session
    ADD CONSTRAINT remote_multicast_class_c_session_pkey PRIMARY KEY (dev_eui, multicast_group_id);


--
-- Name: remote_multicast_setup remote_multicast_setup_pkey; Type: CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.remote_multicast_setup
    ADD CONSTRAINT remote_multicast_setup_pkey PRIMARY KEY (dev_eui, multicast_group_id);


--
-- Name: service_profile service_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.service_profile
    ADD CONSTRAINT service_profile_pkey PRIMARY KEY (service_profile_id);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: idx_application_name_trgm; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_application_name_trgm ON public.application USING gin (name public.gin_trgm_ops);


--
-- Name: idx_application_organization_id; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_application_organization_id ON public.application USING btree (organization_id);


--
-- Name: idx_application_service_profile_id; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_application_service_profile_id ON public.application USING btree (service_profile_id);


--
-- Name: idx_device_activation_dev_eui; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_device_activation_dev_eui ON public.device_activation USING btree (dev_eui);


--
-- Name: idx_device_application_id; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_device_application_id ON public.device USING btree (application_id);


--
-- Name: idx_device_dev_eui_trgm; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_device_dev_eui_trgm ON public.device USING gin (encode(dev_eui, 'hex'::text) public.gin_trgm_ops);


--
-- Name: idx_device_device_profile_id; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_device_device_profile_id ON public.device USING btree (device_profile_id);


--
-- Name: idx_device_name_application_id; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE UNIQUE INDEX idx_device_name_application_id ON public.device USING btree (name, application_id);


--
-- Name: idx_device_name_trgm; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_device_name_trgm ON public.device USING gin (name public.gin_trgm_ops);


--
-- Name: idx_device_profile_network_server_id; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_device_profile_network_server_id ON public.device_profile USING btree (network_server_id);


--
-- Name: idx_device_profile_organization_id; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_device_profile_organization_id ON public.device_profile USING btree (organization_id);


--
-- Name: idx_device_tags; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_device_tags ON public.device USING btree (tags);


--
-- Name: idx_fuota_deployment_multicast_group_id; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_fuota_deployment_multicast_group_id ON public.fuota_deployment USING btree (multicast_group_id);


--
-- Name: idx_fuota_deployment_next_step_after; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_fuota_deployment_next_step_after ON public.fuota_deployment USING btree (next_step_after);


--
-- Name: idx_fuota_deployment_state; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_fuota_deployment_state ON public.fuota_deployment USING btree (state);


--
-- Name: idx_gateway_gateway_profile_id; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_gateway_gateway_profile_id ON public.gateway USING btree (gateway_profile_id);


--
-- Name: idx_gateway_last_ping_sent_at; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_gateway_last_ping_sent_at ON public.gateway USING btree (last_ping_sent_at);


--
-- Name: idx_gateway_mac_trgm; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_gateway_mac_trgm ON public.gateway USING gin (encode(mac, 'hex'::text) public.gin_trgm_ops);


--
-- Name: idx_gateway_name_organization_id; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE UNIQUE INDEX idx_gateway_name_organization_id ON public.gateway USING btree (name, organization_id);


--
-- Name: idx_gateway_name_trgm; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_gateway_name_trgm ON public.gateway USING gin (name public.gin_trgm_ops);


--
-- Name: idx_gateway_network_server_id; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_gateway_network_server_id ON public.gateway USING btree (network_server_id);


--
-- Name: idx_gateway_organization_id; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_gateway_organization_id ON public.gateway USING btree (organization_id);


--
-- Name: idx_gateway_ping; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_gateway_ping ON public.gateway USING btree (ping);


--
-- Name: idx_gateway_ping_gateway_mac; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_gateway_ping_gateway_mac ON public.gateway_ping USING btree (gateway_mac);


--
-- Name: idx_gateway_ping_rx_gateway_mac; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_gateway_ping_rx_gateway_mac ON public.gateway_ping_rx USING btree (gateway_mac);


--
-- Name: idx_gateway_ping_rx_ping_id; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_gateway_ping_rx_ping_id ON public.gateway_ping_rx USING btree (ping_id);


--
-- Name: idx_gateway_profile_network_server_id; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_gateway_profile_network_server_id ON public.gateway_profile USING btree (network_server_id);


--
-- Name: idx_integration_application_id; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_integration_application_id ON public.integration USING btree (application_id);


--
-- Name: idx_integration_kind; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_integration_kind ON public.integration USING btree (kind);


--
-- Name: idx_multicast_group_name_trgm; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_multicast_group_name_trgm ON public.multicast_group USING gin (name public.gin_trgm_ops);


--
-- Name: idx_multicast_group_service_profile_id; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_multicast_group_service_profile_id ON public.multicast_group USING btree (service_profile_id);


--
-- Name: idx_organization_name; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE UNIQUE INDEX idx_organization_name ON public.organization USING btree (name);


--
-- Name: idx_organization_name_trgm; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_organization_name_trgm ON public.organization USING gin (name public.gin_trgm_ops);


--
-- Name: idx_organization_user_organization_id; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_organization_user_organization_id ON public.organization_user USING btree (organization_id);


--
-- Name: idx_organization_user_user_id; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_organization_user_user_id ON public.organization_user USING btree (user_id);


--
-- Name: idx_remote_fragmentation_session_retry_after; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_remote_fragmentation_session_retry_after ON public.remote_fragmentation_session USING btree (retry_after);


--
-- Name: idx_remote_fragmentation_session_state_provisioned; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_remote_fragmentation_session_state_provisioned ON public.remote_fragmentation_session USING btree (state_provisioned);


--
-- Name: idx_remote_multicast_class_c_session_state_provisioned; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_remote_multicast_class_c_session_state_provisioned ON public.remote_multicast_class_c_session USING btree (state_provisioned);


--
-- Name: idx_remote_multicast_class_c_session_state_retry_after; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_remote_multicast_class_c_session_state_retry_after ON public.remote_multicast_class_c_session USING btree (retry_after);


--
-- Name: idx_remote_multicast_setup_retry_after; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_remote_multicast_setup_retry_after ON public.remote_multicast_setup USING btree (retry_after);


--
-- Name: idx_remote_multicast_setup_state_provisioned; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_remote_multicast_setup_state_provisioned ON public.remote_multicast_setup USING btree (state_provisioned);


--
-- Name: idx_service_profile_network_server_id; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_service_profile_network_server_id ON public.service_profile USING btree (network_server_id);


--
-- Name: idx_service_profile_organization_id; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_service_profile_organization_id ON public.service_profile USING btree (organization_id);


--
-- Name: idx_user_username; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE UNIQUE INDEX idx_user_username ON public."user" USING btree (username);


--
-- Name: idx_user_username_trgm; Type: INDEX; Schema: public; Owner: chirpstack_as
--

CREATE INDEX idx_user_username_trgm ON public."user" USING gin (username public.gin_trgm_ops);


--
-- Name: application application_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.application
    ADD CONSTRAINT application_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON DELETE CASCADE;


--
-- Name: application application_service_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.application
    ADD CONSTRAINT application_service_profile_id_fkey FOREIGN KEY (service_profile_id) REFERENCES public.service_profile(service_profile_id);


--
-- Name: device_activation device_activation_dev_eui_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.device_activation
    ADD CONSTRAINT device_activation_dev_eui_fkey FOREIGN KEY (dev_eui) REFERENCES public.device(dev_eui) ON DELETE CASCADE;


--
-- Name: device device_application_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.device
    ADD CONSTRAINT device_application_id_fkey FOREIGN KEY (application_id) REFERENCES public.application(id);


--
-- Name: device device_device_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.device
    ADD CONSTRAINT device_device_profile_id_fkey FOREIGN KEY (device_profile_id) REFERENCES public.device_profile(device_profile_id);


--
-- Name: device_keys device_keys_dev_eui_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.device_keys
    ADD CONSTRAINT device_keys_dev_eui_fkey FOREIGN KEY (dev_eui) REFERENCES public.device(dev_eui) ON DELETE CASCADE;


--
-- Name: device_multicast_group device_multicast_group_dev_eui_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.device_multicast_group
    ADD CONSTRAINT device_multicast_group_dev_eui_fkey FOREIGN KEY (dev_eui) REFERENCES public.device(dev_eui) ON DELETE CASCADE;


--
-- Name: device_multicast_group device_multicast_group_multicast_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.device_multicast_group
    ADD CONSTRAINT device_multicast_group_multicast_group_id_fkey FOREIGN KEY (multicast_group_id) REFERENCES public.multicast_group(id) ON DELETE CASCADE;


--
-- Name: device_profile device_profile_network_server_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.device_profile
    ADD CONSTRAINT device_profile_network_server_id_fkey FOREIGN KEY (network_server_id) REFERENCES public.network_server(id);


--
-- Name: device_profile device_profile_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.device_profile
    ADD CONSTRAINT device_profile_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organization(id);


--
-- Name: fuota_deployment_device fuota_deployment_device_dev_eui_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.fuota_deployment_device
    ADD CONSTRAINT fuota_deployment_device_dev_eui_fkey FOREIGN KEY (dev_eui) REFERENCES public.device(dev_eui) ON DELETE CASCADE;


--
-- Name: fuota_deployment_device fuota_deployment_device_fuota_deployment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.fuota_deployment_device
    ADD CONSTRAINT fuota_deployment_device_fuota_deployment_id_fkey FOREIGN KEY (fuota_deployment_id) REFERENCES public.fuota_deployment(id) ON DELETE CASCADE;


--
-- Name: fuota_deployment fuota_deployment_multicast_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.fuota_deployment
    ADD CONSTRAINT fuota_deployment_multicast_group_id_fkey FOREIGN KEY (multicast_group_id) REFERENCES public.multicast_group(id) ON DELETE SET NULL;


--
-- Name: gateway gateway_gateway_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.gateway
    ADD CONSTRAINT gateway_gateway_profile_id_fkey FOREIGN KEY (gateway_profile_id) REFERENCES public.gateway_profile(gateway_profile_id);


--
-- Name: gateway gateway_last_ping_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.gateway
    ADD CONSTRAINT gateway_last_ping_id_fkey FOREIGN KEY (last_ping_id) REFERENCES public.gateway_ping(id) ON DELETE SET NULL;


--
-- Name: gateway gateway_network_server_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.gateway
    ADD CONSTRAINT gateway_network_server_id_fkey FOREIGN KEY (network_server_id) REFERENCES public.network_server(id);


--
-- Name: gateway gateway_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.gateway
    ADD CONSTRAINT gateway_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON DELETE CASCADE;


--
-- Name: gateway_ping gateway_ping_gateway_mac_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.gateway_ping
    ADD CONSTRAINT gateway_ping_gateway_mac_fkey FOREIGN KEY (gateway_mac) REFERENCES public.gateway(mac) ON DELETE CASCADE;


--
-- Name: gateway_ping_rx gateway_ping_rx_gateway_mac_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.gateway_ping_rx
    ADD CONSTRAINT gateway_ping_rx_gateway_mac_fkey FOREIGN KEY (gateway_mac) REFERENCES public.gateway(mac) ON DELETE CASCADE;


--
-- Name: gateway_ping_rx gateway_ping_rx_ping_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.gateway_ping_rx
    ADD CONSTRAINT gateway_ping_rx_ping_id_fkey FOREIGN KEY (ping_id) REFERENCES public.gateway_ping(id) ON DELETE CASCADE;


--
-- Name: gateway_profile gateway_profile_network_server_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.gateway_profile
    ADD CONSTRAINT gateway_profile_network_server_id_fkey FOREIGN KEY (network_server_id) REFERENCES public.network_server(id);


--
-- Name: integration integration_application_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.integration
    ADD CONSTRAINT integration_application_id_fkey FOREIGN KEY (application_id) REFERENCES public.application(id) ON DELETE CASCADE;


--
-- Name: multicast_group multicast_group_service_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.multicast_group
    ADD CONSTRAINT multicast_group_service_profile_id_fkey FOREIGN KEY (service_profile_id) REFERENCES public.service_profile(service_profile_id);


--
-- Name: organization_user organization_user_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.organization_user
    ADD CONSTRAINT organization_user_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON DELETE CASCADE;


--
-- Name: organization_user organization_user_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.organization_user
    ADD CONSTRAINT organization_user_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: remote_fragmentation_session remote_fragmentation_session_dev_eui_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.remote_fragmentation_session
    ADD CONSTRAINT remote_fragmentation_session_dev_eui_fkey FOREIGN KEY (dev_eui) REFERENCES public.device(dev_eui) ON DELETE CASCADE;


--
-- Name: remote_multicast_class_c_session remote_multicast_class_c_session_dev_eui_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.remote_multicast_class_c_session
    ADD CONSTRAINT remote_multicast_class_c_session_dev_eui_fkey FOREIGN KEY (dev_eui) REFERENCES public.device(dev_eui) ON DELETE CASCADE;


--
-- Name: remote_multicast_class_c_session remote_multicast_class_c_session_multicast_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.remote_multicast_class_c_session
    ADD CONSTRAINT remote_multicast_class_c_session_multicast_group_id_fkey FOREIGN KEY (multicast_group_id) REFERENCES public.multicast_group(id) ON DELETE CASCADE;


--
-- Name: remote_multicast_setup remote_multicast_setup_dev_eui_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.remote_multicast_setup
    ADD CONSTRAINT remote_multicast_setup_dev_eui_fkey FOREIGN KEY (dev_eui) REFERENCES public.device(dev_eui) ON DELETE CASCADE;


--
-- Name: remote_multicast_setup remote_multicast_setup_multicast_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.remote_multicast_setup
    ADD CONSTRAINT remote_multicast_setup_multicast_group_id_fkey FOREIGN KEY (multicast_group_id) REFERENCES public.multicast_group(id) ON DELETE CASCADE;


--
-- Name: service_profile service_profile_network_server_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.service_profile
    ADD CONSTRAINT service_profile_network_server_id_fkey FOREIGN KEY (network_server_id) REFERENCES public.network_server(id);


--
-- Name: service_profile service_profile_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chirpstack_as
--

ALTER TABLE ONLY public.service_profile
    ADD CONSTRAINT service_profile_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organization(id);

--
-- PostgreSQL database dump complete
--
