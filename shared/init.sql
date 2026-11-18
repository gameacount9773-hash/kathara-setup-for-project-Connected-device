CREATE DATABASE factory_db; -- Create a new, empty database called "factory_db".
-- Connect to the new database (backslash c = connect)
\c factory_db
-- What kind of sensor, and what are its rules? (stored once per kind)
CREATE TABLE sensor_type (
    type_id         INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- GENERATED ALWAYS AS IDENTITY = the database numbers rows itself (1, 2, 3…).
    name            TEXT NOT NULL UNIQUE,
    unit            TEXT NOT NULL, -- "unit": the unit of measurement (°C, kg, V)
    warning_limit   DOUBLE PRECISION,
    alarm_limit     DOUBLE PRECISION,
    send_interval_s INT  NOT NULL CHECK (send_interval_s > 0),
    CHECK (warning_limit IS NULL OR alarm_limit IS NULL OR warning_limit < alarm_limit)-- the warning must be LOWER than the alarm.
                                                                    -- (If one of them is missing, there's nothing to compare, so it's fine.)
);
-- Where in the hall? One zone = one VLAN.
CREATE TABLE zone (
    zone_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name    TEXT NOT NULL UNIQUE,
    vlan_id INT  NOT NULL UNIQUE CHECK (vlan_id BETWEEN 1 AND 4094) --It must be between 1 and 4094,
                                                    -- because those are the valid VLAN numbers
);
-- Which sensor is it?
CREATE TABLE sensor (
    sensor_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,  -- Automatic unique number for the sensor
    name        TEXT    NOT NULL UNIQUE,            
    zone_id     INT     NOT NULL REFERENCES zone(zone_id), -- Which zone it's in
    type_id     INT     NOT NULL REFERENCES sensor_type(type_id),  -- What kind of sensor it is
    ip_address  INET    UNIQUE,
    mac_address MACADDR UNIQUE
);
-- What was measured, and did it arrive in time? (TimescaleDB hypertable)
CREATE TABLE measurement (
    time            TIMESTAMPTZ      NOT NULL,      -- when the sensor measured
    sensor_id       INT              NOT NULL REFERENCES sensor(sensor_id),
    sequence_number INT           NOT NULL CHECK (sequence_number >= 0),  -- The message's counter
    value           DOUBLE PRECISION NOT NULL,
    received_at     TIMESTAMPTZ      NOT NULL DEFAULT now(),  -- when it arrived
    UNIQUE (sensor_id, time) -- One sensor can't have two readings at the exact same moment (no duplicates)
);
CREATE INDEX ON measurement (sensor_id, time DESC);  -- for fast searching.It's sorted by sensor, then by time from newest to oldest
CREATE TABLE alarm (
    alarm_id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,  -- Automatic number for the alarm.
    sensor_id INT              NOT NULL REFERENCES sensor(sensor_id),  -- Which sensor triggered it.
    time      TIMESTAMPTZ      NOT NULL,  -- When it happened.
    level     TEXT             NOT NULL CHECK (level IN ('warning', 'alarm')), -- The level 'warning' or 'alarm'
    value     DOUBLE PRECISION NOT NULL,    -- The value that was measured.
    threshold DOUBLE PRECISION NOT NULL           --  the limit at that moment
);
CREATE INDEX ON alarm (time DESC);

-- What is this battery?
CREATE TABLE battery (
    battery_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,   -- Automatic number for the battery.
    chemistry  TEXT,  -- Chemistry ("Li-ion", "NiMH")
    weight_kg  NUMERIC(8,3)     CHECK (weight_kg > 0),
    voltage    DOUBLE PRECISION CHECK (voltage >= 0),  -- Voltage. Can't be negative (0 is fine and means a flat battery)
    condition  TEXT             CHECK (condition IN ('ok', 'damaged', 'unknown'))  -- Condition: ONLY 'ok', 'damaged' or 'unknown'.
);

-- What happened to it, where, and what went wrong?
CREATE TABLE battery_event (
    event_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Automatic number for the event.
    battery_id INT         NOT NULL REFERENCES battery(battery_id),   -- Which battery
    sensor_id  INT         REFERENCES sensor(sensor_id),   -- Which sensor detected it
    time       TIMESTAMPTZ NOT NULL DEFAULT now(),
    step       TEXT        NOT NULL CHECK (step   IN ('received', 'inspected', 'discharged')),
    result     TEXT        NOT NULL CHECK (result IN ('ok', 'rejected', 'error')),
    error_code TEXT        CHECK (error_code IN
                 ('WEIGHT_INVALID', 'DAMAGED', 'VOLTAGE_HIGH', 'DISCHARGE_TIMEOUT')),
    -- ok -> no error code;  rejected/error -> error code required
    CHECK ((result = 'ok') = (error_code IS NULL)) --   "is the result ok?"  and  "is the error code empty?"
);
CREATE INDEX ON battery_event (battery_id);

-- TimescaleDB: turn measurement into a hypertable when the extension is installed.
-- Without it, measurement simply stays a normal table and everything else works.
DO $$
BEGIN
    CREATE EXTENSION IF NOT EXISTS timescaledb;
    PERFORM create_hypertable('measurement', by_range('time', INTERVAL '1 day'));
    RAISE NOTICE 'TimescaleDB active: measurement is a hypertable';
EXCEPTION WHEN others THEN
    RAISE NOTICE 'TimescaleDB not available (%): measurement stays a normal table', SQLERRM;
END $$;
-- Fixed data. VLAN IDs, IP and MAC addresses are EXAMPLES:
-- replace them with the values from your Kathará lab and DHCP configuration.
INSERT INTO sensor_type (name, unit, warning_limit, alarm_limit, send_interval_s) VALUES
  ('Temperature',       '°C',       45,   60,  1),
  ('Carbon monoxide',   'ppm',      35,  200,  1),
  ('Hydrogen',          '% LEL',    10,   25,  1),
  ('Hydrogen fluoride', 'ppm',       3,    6,  1),
  ('Smoke',             '0/1',    NULL,    1, 10),
  ('Voltage',           'V/cell', NULL,  2.0,  1),
  ('Vibration',         'mm/s',    3.5,  4.5, 10),
  ('Weight',            'kg',     NULL, NULL,  1);

INSERT INTO zone (name, vlan_id) VALUES
  ('Safety',            10),
  ('Sorting',           20),
  ('Management & Edge', 30);

INSERT INTO sensor (name, zone_id, type_id, ip_address, mac_address)
SELECT s.name, z.zone_id, t.type_id, s.ip::inet, s.mac::macaddr
FROM (VALUES
  ('TEMP-RACK-01', 'Safety',  'Temperature',       '10.0.10.11', '02:00:00:00:10:11'),
  ('TEMP-RACK-02', 'Safety',  'Temperature',       '10.0.10.12', '02:00:00:00:10:12'),
  ('TEMP-RACK-03', 'Safety',  'Temperature',       '10.0.10.13', '02:00:00:00:10:13'),
  ('CO-HALL-01',   'Safety',  'Carbon monoxide',   '10.0.10.21', '02:00:00:00:10:21'),
  ('H2-CEIL-01',   'Safety',  'Hydrogen',          '10.0.10.22', '02:00:00:00:10:22'),
  ('HF-HALL-01',   'Safety',  'Hydrogen fluoride', '10.0.10.23', '02:00:00:00:10:23'),
  ('SMOKE-01',     'Safety',  'Smoke',             '10.0.10.31', '02:00:00:00:10:31'),
  ('WEIGHT-IN-01', 'Sorting', 'Weight',            '10.0.20.11', '02:00:00:00:20:11'),
  ('DISCH-01',     'Sorting', 'Voltage',           '10.0.20.21', '02:00:00:00:20:21'),
  ('VIB-CONV-01',  'Sorting', 'Vibration',         '10.0.20.31', '02:00:00:00:20:31')
) AS s(name, zone, type, ip, mac)
JOIN zone z        ON z.name = s.zone
JOIN sensor_type t ON t.name = s.type
ORDER BY s.ip::inet;   -- keeps IDs in list order: TEMP-RACK-01 = 1 ... VIB-CONV-01 = 10

-- Logins: one per part, only the rights it needs. Change the passwords before the demo.

-- Edge gateway: reads the sensor list and limits, only ADDS data.
CREATE ROLE gateway_writer LOGIN PASSWORD 'Gateway-Write-26';
GRANT CONNECT ON DATABASE factory_db TO gateway_writer;
GRANT USAGE  ON SCHEMA public TO gateway_writer;
GRANT SELECT ON sensor, sensor_type, zone TO gateway_writer;
GRANT INSERT ON measurement, alarm, battery, battery_event TO gateway_writer;
GRANT SELECT ON battery TO gateway_writer;   -- needed for INSERT ... RETURNING battery_id

-- pandas analysis: read only.
CREATE ROLE analysis_user LOGIN PASSWORD 'Analysis-Read-26';
GRANT CONNECT ON DATABASE factory_db TO analysis_user;
GRANT USAGE  ON SCHEMA public TO analysis_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO analysis_user;

-- Grafana dashboards: read only.
CREATE ROLE grafana_reader LOGIN PASSWORD 'Grafana-Read-26';
GRANT CONNECT ON DATABASE factory_db TO grafana_reader;
GRANT USAGE  ON SCHEMA public TO grafana_reader;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO grafana_reader;