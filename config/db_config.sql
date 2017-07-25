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
  test_start integer NOT NULL,
  test_end integer NOT NULL,
  test_time_cost_of_sec double precision NOT NULL,
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

-- table for perfmon metrics
CREATE TABLE jmeter_perfmon_metric
(
  id serial NOT NULL,
  testid character varying NOT NULL,
  metric_type VARCHAR not NULL ,-- cpu/memory/disk/network/tcp/jmx
  label character varying NOT NULL,
  time_stamp_str character varying NOT NULL,
  value_str character varying NOT NULL,
  CONSTRAINT jmeter_perfmon_metric_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE jmeter_perfmon_metric
  OWNER TO postgres;

CREATE INDEX ON jmeter_perfmon_metric (testid);

--
-- table for jmeter_function_test_result
CREATE TABLE jmeter_function_test_result
(
  id serial NOT NULL,
  testid character varying NOT NULL,
  response_code int not NULL ,
  response_body text,
  time_stamp TIMESTAMP NOT NULL,
  CONSTRAINT jmeter_function_test_result_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE jmeter_function_test_result
  OWNER TO postgres;

CREATE INDEX ON jmeter_function_test_result (testid);