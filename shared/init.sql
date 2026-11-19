-- ==========================================
-- 1. Core Tables
-- ==========================================
CREATE TABLE IF NOT EXISTS sensor_type (
    type_id         INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name            TEXT NOT NULL UNIQUE,
    unit            TEXT NOT NULL,
    warning_limit   DOUBLE PRECISION,
    alarm_limit     DOUBLE PRECISION,
    send_interval_s INT  NOT NULL CHECK (send_interval_s > 0),
    CHECK (warning_limit IS NULL OR alarm_limit IS NULL OR warning_limit < alarm_limit)
);

CREATE TABLE IF NOT EXISTS zone (
    zone_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name    TEXT NOT NULL UNIQUE,
    vlan_id INT  NOT NULL UNIQUE CHECK (vlan_id BETWEEN 1 AND 4094)
);

CREATE TABLE IF NOT EXISTS sensor (
    sensor_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        TEXT    NOT NULL UNIQUE,
    zone_id     INT     NOT NULL REFERENCES zone(zone_id),
    type_id     INT     NOT NULL REFERENCES sensor_type(type_id),
    ip_address  INET    UNIQUE,
    mac_address MACADDR UNIQUE
);

CREATE TABLE IF NOT EXISTS measurement (
    time             TIMESTAMPTZ      NOT NULL,
    sensor_id        INT              NOT NULL REFERENCES sensor(sensor_id),
    sequence_number  INT              NOT NULL CHECK (sequence_number >= 0),
    value            DOUBLE PRECISION NOT NULL,
    battery_type     TEXT,
    confidence_score DOUBLE PRECISION,
    raw_condition    TEXT,
    received_at      TIMESTAMPTZ      NOT NULL DEFAULT now(),
    UNIQUE (sensor_id, time)
);
CREATE INDEX IF NOT EXISTS measurement_sensor_id_time_idx ON measurement (sensor_id, time DESC);

CREATE TABLE IF NOT EXISTS alarm (
    alarm_id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sensor_id INT              NOT NULL REFERENCES sensor(sensor_id),
    time      TIMESTAMPTZ      NOT NULL,
    level     TEXT             NOT NULL CHECK (level IN ('warning', 'alarm')),
    value     DOUBLE PRECISION NOT NULL,
    threshold DOUBLE PRECISION NOT NULL
);
CREATE INDEX IF NOT EXISTS alarm_time_idx ON alarm (time DESC);

CREATE TABLE IF NOT EXISTS battery (
    battery_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    chemistry  TEXT,
    weight_kg  NUMERIC(8,3)     CHECK (weight_kg > 0),
    voltage    DOUBLE PRECISION CHECK (voltage >= 0),
    condition  TEXT             CHECK (condition IN ('ok', 'damaged', 'unknown'))
);

CREATE TABLE IF NOT EXISTS battery_event (
    event_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    battery_id INT         NOT NULL REFERENCES battery(battery_id),
    sensor_id  INT         REFERENCES sensor(sensor_id),
    time       TIMESTAMPTZ NOT NULL DEFAULT now(),
    step       TEXT        NOT NULL CHECK (step   IN ('received', 'inspected', 'discharged')),
    result     TEXT        NOT NULL CHECK (result IN ('ok', 'rejected', 'error')),
    error_code TEXT        CHECK (error_code IN
                 ('WEIGHT_INVALID', 'DAMAGED', 'VOLTAGE_HIGH', 'DISCHARGE_TIMEOUT')),
    CHECK ((result = 'ok') = (error_code IS NULL))
);
CREATE INDEX IF NOT EXISTS battery_event_battery_id_idx ON battery_event (battery_id);

-- ==========================================
-- 2. TimescaleDB Hypertable Setup
-- ==========================================
DO $$
BEGIN
    CREATE EXTENSION IF NOT EXISTS timescaledb;
    PERFORM create_hypertable('measurement', by_range('time', INTERVAL '1 day'), if_not_exists => TRUE);
    RAISE NOTICE 'TimescaleDB active: measurement is a hypertable';
EXCEPTION WHEN others THEN
    RAISE NOTICE 'TimescaleDB not available (%): measurement stays a normal table', SQLERRM;
END $$;

-- ==========================================
-- 3. Seed Data (Sensor Types, Zones, Sensors)
-- ==========================================
INSERT INTO sensor_type (name, unit, warning_limit, alarm_limit, send_interval_s) VALUES
  ('Temperature',       '°C',       45,   60,  1),
  ('Carbon monoxide',   'ppm',      35,  200,  1),
  ('Hydrogen',          '% LEL',    10,   25,  1),
  ('Hydrogen fluoride', 'ppm',       3,    6,  1),
  ('Smoke',             '0/1',    NULL,    1, 10),
  ('Voltage',           'V/cell', NULL,  2.0,  1),
  ('Vibration',         'mm/s',    3.5,  4.5, 10),
  ('Weight',            'kg',     NULL, NULL,  1),
  ('Magnetic',          '0/1',    NULL, NULL,  1),
  ('Vision',            'class',  NULL, NULL,  1)
ON CONFLICT (name) DO NOTHING;

INSERT INTO zone (name, vlan_id) VALUES
  ('Management & Edge', 1),
  ('Safety',            10),
  ('Sorting',           20)
ON CONFLICT (name) DO NOTHING;

INSERT INTO sensor (name, zone_id, type_id, ip_address, mac_address)
SELECT s.name, z.zone_id, t.type_id, s.ip::inet, s.mac::macaddr
FROM (VALUES
  -- Safety Zone (vlan_safety: 192.168.10.0/24)
  ('temp_01',      'Safety',  'Temperature',       '192.168.10.11', '02:00:00:00:10:11'),
  ('co_01',        'Safety',  'Carbon monoxide',   '192.168.10.12', '02:00:00:00:10:12'),
  ('h2_01',        'Safety',  'Hydrogen',          '192.168.10.13', '02:00:00:00:10:13'),
  ('hf_01',        'Safety',  'Hydrogen fluoride', '192.168.10.14', '02:00:00:00:10:14'),
  ('smoke_01',     'Safety',  'Smoke',             '192.168.10.15', '02:00:00:00:10:15'),
  -- Sorting Zone (vlan_sorting: 192.168.20.0/24)
  ('weight_01',    'Sorting', 'Weight',            '192.168.20.11', '02:00:00:00:20:11'),
  ('voltage_01',      'Sorting', 'Voltage',           '192.168.20.12', '02:00:00:00:20:12'),
  ('vibration_01', 'Sorting', 'Vibration',         '192.168.20.13', '02:00:00:00:20:13'),
  ('magnetic_01',  'Sorting', 'Magnetic',          '192.168.20.14', '02:00:00:00:20:14'),
  ('vision_01',    'Sorting', 'Vision',            '192.168.20.15', '02:00:00:00:20:15')
) AS s(name, zone, type, ip, mac)
JOIN zone z        ON z.name = s.zone
JOIN sensor_type t ON t.name = s.type
ON CONFLICT (name) DO NOTHING;

-- ==========================================
-- 4. RBAC Roles & Privileges
-- ==========================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'gateway_writer') THEN
        CREATE ROLE gateway_writer LOGIN PASSWORD 'Gateway-Write-26';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'analysis_user') THEN
        CREATE ROLE analysis_user LOGIN PASSWORD 'Analysis-Read-26';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'grafana_reader') THEN
        CREATE ROLE grafana_reader LOGIN PASSWORD 'Grafana-Read-26';
    END IF;
END $$;

GRANT CONNECT ON DATABASE factory_db TO gateway_writer;
GRANT USAGE  ON SCHEMA public TO gateway_writer;
GRANT SELECT ON sensor, sensor_type, zone TO gateway_writer;
GRANT INSERT ON measurement, alarm, battery, battery_event TO gateway_writer;
GRANT SELECT ON battery TO gateway_writer;

GRANT CONNECT ON DATABASE factory_db TO analysis_user;
GRANT USAGE  ON SCHEMA public TO analysis_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO analysis_user;

GRANT CONNECT ON DATABASE factory_db TO grafana_reader;
GRANT USAGE  ON SCHEMA public TO grafana_reader;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO grafana_reader;

