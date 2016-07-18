--------------------------
-- DataBase: PostgreSQL DB
--------------------------

-- 1. create a new DB named 'restjmeter'
-- 2. create 2 tables:
--    1) jmeter_aggregate_report
--    2) jmeter_jmx_log

CREATE TABLE jmeter_aggregate_report
(
  id serial NOT NULL,
  testid character varying NOT NULL,
  time_stamp integer NOT NULL,
  label character varying NOT NULL,
  samples integer NOT NULL,
  average integer NOT NULL,
  median integer NOT NULL,
  perc90_line integer NOT NULL,
  perc95_line integer,
  perc99_line integer,
  min integer NOT NULL,
  max integer NOT NULL,
  error_rate double precision DEFAULT 0,
  throughput double precision,
  kb_per_sec double precision,
  CONSTRAINT jmeter_aggregate_report_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE jmeter_aggregate_report
  OWNER TO postgres;

CREATE TABLE jmeter_jmx_log
(
  id serial NOT NULL,
  testid character varying NOT NULL,
  status character varying NOT NULL,
  time_stamp integer NOT NULL,
  jmx_content character varying,
  CONSTRAINT jmeter_jmx_log_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE jmeter_jmx_log
  OWNER TO postgres;