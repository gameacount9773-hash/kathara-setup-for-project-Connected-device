-- fake_data.sql  –  Simple test data, one row = one INSERT (run AFTER init.sql, only ONCE)
-- docker cp shared\fake_data.sql iot_database:/tmp/fake_data.sql
-- docker exec -it iot_database psql -U postgres -d factory_db -f /tmp/fake_data.sql
-- (SELECT sensor_id FROM sensor WHERE name = '...') finds the sensor's number by its name.


-- ===== MEASUREMENT temp_01 (Temperature, °C) =====
INSERT INTO measurement (time, sensor_id, sequence_number, value, received_at)
VALUES (now() - interval '5 minutes', (SELECT sensor_id FROM sensor WHERE name = 'temp_01'), 1, 30.2, now() - interval '5 minutes' + interval '0.1 seconds');
INSERT INTO measurement (time, sensor_id, sequence_number, value, received_at)
VALUES (now() - interval '4 minutes', (SELECT sensor_id FROM sensor WHERE name = 'temp_01'), 2, 48.0, now() - interval '4 minutes' + interval '0.1 seconds');  -- WARNING: above 45
INSERT INTO measurement (time, sensor_id, sequence_number, value, received_at)
VALUES (now() - interval '3 minutes', (SELECT sensor_id FROM sensor WHERE name = 'temp_01'), 3, 31.0, now() - interval '3 minutes' + interval '0.1 seconds');
INSERT INTO measurement (time, sensor_id, sequence_number, value, received_at)
VALUES (now() - interval '2 minutes', (SELECT sensor_id FROM sensor WHERE name = 'temp_01'), 4, 61.5, now() - interval '2 minutes' + interval '0.1 seconds');  -- ALARM: above 60
INSERT INTO measurement (time, sensor_id, sequence_number, value, received_at)
VALUES (now() - interval '1 minutes', (SELECT sensor_id FROM sensor WHERE name = 'temp_01'), 5, 30.5, now() - interval '1 minutes' + interval '0.1 seconds');

-- ===== MEASUREMENT: co_01 (Carbon monoxide, ppm) =====
INSERT INTO measurement (time, sensor_id, sequence_number, value, received_at)
VALUES (now() - interval '5 minutes', (SELECT sensor_id FROM sensor WHERE name = 'co_01'), 1, 3.1, now() - interval '5 minutes' + interval '0.1 seconds');
INSERT INTO measurement (time, sensor_id, sequence_number, value, received_at)
VALUES (now() - interval '4 minutes', (SELECT sensor_id FROM sensor WHERE name = 'co_01'), 2, 2.8, now() - interval '4 minutes' + interval '0.1 seconds');
INSERT INTO measurement (time, sensor_id, sequence_number, value, received_at)
VALUES (now() - interval '3 minutes', (SELECT sensor_id FROM sensor WHERE name = 'co_01'), 3, 210, now() - interval '3 minutes' + interval '0.1 seconds');  -- ALARM: above 200
INSERT INTO measurement (time, sensor_id, sequence_number, value, received_at)
VALUES (now() - interval '1 minutes', (SELECT sensor_id FROM sensor WHERE name = 'co_01'), 5, 3.0, now() - interval '1 minutes' + interval '0.1 seconds');  -- message 4 is missing = LOST

-- ===== MEASUREMENT: hf_01 (Hydrogen fluoride, ppm) =====
INSERT INTO measurement (time, sensor_id, sequence_number, value, received_at)
VALUES (now() - interval '3 minutes', (SELECT sensor_id FROM sensor WHERE name = 'hf_01'), 1, 0.2, now() - interval '3 minutes' + interval '0.1 seconds');
INSERT INTO measurement (time, sensor_id, sequence_number, value, received_at)
VALUES (now() - interval '2 minutes', (SELECT sensor_id FROM sensor WHERE name = 'hf_01'), 2, 0.3, now() - interval '2 minutes' + interval '3 seconds');  -- arrived 3 s late = DELAYED
INSERT INTO measurement (time, sensor_id, sequence_number, value, received_at)
VALUES (now() - interval '1 minutes', (SELECT sensor_id FROM sensor WHERE name = 'hf_01'), 3, 0.2, now() - interval '1 minutes' + interval '0.1 seconds');

-- ===== MEASUREMENT: h2_01 (Hydrogen, % LEL) =====
INSERT INTO measurement (time, sensor_id, sequence_number, value, received_at)
VALUES (now() - interval '3 minutes', (SELECT sensor_id FROM sensor WHERE name = 'h2_01'), 1, 0.5, now() - interval '3 minutes' + interval '0.1 seconds');
INSERT INTO measurement (time, sensor_id, sequence_number, value, received_at)
VALUES (now() - interval '2 minutes', (SELECT sensor_id FROM sensor WHERE name = 'h2_01'), 2, 0.7, now() - interval '2 minutes' + interval '0.1 seconds');
INSERT INTO measurement (time, sensor_id, sequence_number, value, received_at)
VALUES (now() - interval '1 minutes', (SELECT sensor_id FROM sensor WHERE name = 'h2_01'), 3, 0.4, now() - interval '1 minutes' + interval '0.1 seconds');

-- ===== MEASUREMENT: smoke_01 (Smoke, 0 = no smoke) =====
INSERT INTO measurement (time, sensor_id, sequence_number, value, received_at)
VALUES (now() - interval '3 minutes', (SELECT sensor_id FROM sensor WHERE name = 'smoke_01'), 1, 0, now() - interval '3 minutes' + interval '0.1 seconds');
INSERT INTO measurement (time, sensor_id, sequence_number, value, received_at)
VALUES (now() - interval '2 minutes', (SELECT sensor_id FROM sensor WHERE name = 'smoke_01'), 2, 0, now() - interval '2 minutes' + interval '0.1 seconds');
INSERT INTO measurement (time, sensor_id, sequence_number, value, received_at)
VALUES (now() - interval '1 minutes', (SELECT sensor_id FROM sensor WHERE name = 'smoke_01'), 3, 0, now() - interval '1 minutes' + interval '0.1 seconds');

-- ===== MEASUREMENT: weight_01 (Weight, kg) =====
INSERT INTO measurement (time, sensor_id, sequence_number, value, received_at)
VALUES (now() - interval '3 minutes', (SELECT sensor_id FROM sensor WHERE name = 'weight_01'), 1, 4.5, now() - interval '3 minutes' + interval '0.1 seconds');
INSERT INTO measurement (time, sensor_id, sequence_number, value, received_at)
VALUES (now() - interval '2 minutes', (SELECT sensor_id FROM sensor WHERE name = 'weight_01'), 2, 12.3, now() - interval '2 minutes' + interval '0.1 seconds');
INSERT INTO measurement (time, sensor_id, sequence_number, value, received_at)
VALUES (now() - interval '1 minutes', (SELECT sensor_id FROM sensor WHERE name = 'weight_01'), 3, 7.6, now() - interval '1 minutes' + interval '0.1 seconds');

-- ===== MEASUREMENT: voltage_01 (Voltage, V per cell) =====
INSERT INTO measurement (time, sensor_id, sequence_number, value, received_at)
VALUES (now() - interval '3 minutes', (SELECT sensor_id FROM sensor WHERE name = 'voltage_01'), 1, 2.8, now() - interval '3 minutes' + interval '0.1 seconds');
INSERT INTO measurement (time, sensor_id, sequence_number, value, received_at)
VALUES (now() - interval '2 minutes', (SELECT sensor_id FROM sensor WHERE name = 'voltage_01'), 2, 2.1, now() - interval '2 minutes' + interval '0.1 seconds');
INSERT INTO measurement (time, sensor_id, sequence_number, value, received_at)
VALUES (now() - interval '1 minutes', (SELECT sensor_id FROM sensor WHERE name = 'voltage_01'), 3, 1.8, now() - interval '1 minutes' + interval '0.1 seconds');

-- ===== MEASUREMENT: magnetic_01 (Magnetic, 1 = metal detected) =====
INSERT INTO measurement (time, sensor_id, sequence_number, value, received_at)
VALUES (now() - interval '3 minutes', (SELECT sensor_id FROM sensor WHERE name = 'magnetic_01'), 1, 0, now() - interval '3 minutes' + interval '0.1 seconds');
INSERT INTO measurement (time, sensor_id, sequence_number, value, received_at)
VALUES (now() - interval '2 minutes', (SELECT sensor_id FROM sensor WHERE name = 'magnetic_01'), 2, 1, now() - interval '2 minutes' + interval '0.1 seconds');
INSERT INTO measurement (time, sensor_id, sequence_number, value, received_at)
VALUES (now() - interval '1 minutes', (SELECT sensor_id FROM sensor WHERE name = 'magnetic_01'), 3, 0, now() - interval '1 minutes' + interval '0.1 seconds');

-- ===== MEASUREMENT: vibration_01 (Vibration, mm/s) – stopped 10 minutes ago = OFFLINE =====
INSERT INTO measurement (time, sensor_id, sequence_number, value, received_at)
VALUES (now() - interval '12 minutes', (SELECT sensor_id FROM sensor WHERE name = 'vibration_01'), 1, 1.8, now() - interval '12 minutes' + interval '0.1 seconds');
INSERT INTO measurement (time, sensor_id, sequence_number, value, received_at)
VALUES (now() - interval '11 minutes', (SELECT sensor_id FROM sensor WHERE name = 'vibration_01'), 2, 2.1, now() - interval '11 minutes' + interval '0.1 seconds');
INSERT INTO measurement (time, sensor_id, sequence_number, value, received_at)
VALUES (now() - interval '10 minutes', (SELECT sensor_id FROM sensor WHERE name = 'vibration_01'), 3, 1.9, now() - interval '10 minutes' + interval '0.1 seconds');

-- ===== MEASUREMENT: vision_01 (camera) – value 0 = Good, 1 = damaged; 3 extra camera columns =====
INSERT INTO measurement (time, sensor_id, sequence_number, value, battery_type, confidence_score, raw_condition, received_at)
VALUES (now() - interval '3 minutes', (SELECT sensor_id FROM sensor WHERE name = 'vision_01'), 1, 0, '18650', 97.4, 'Good', now() - interval '3 minutes' + interval '0.1 seconds');
INSERT INTO measurement (time, sensor_id, sequence_number, value, battery_type, confidence_score, raw_condition, received_at)
VALUES (now() - interval '2 minutes', (SELECT sensor_id FROM sensor WHERE name = 'vision_01'), 2, 1, 'Pouch', 93.1, 'Swollen', now() - interval '2 minutes' + interval '0.1 seconds');
INSERT INTO measurement (time, sensor_id, sequence_number, value, battery_type, confidence_score, raw_condition, received_at)
VALUES (now() - interval '1 minutes', (SELECT sensor_id FROM sensor WHERE name = 'vision_01'), 3, 0, 'AA', 99.2, 'Good', now() - interval '1 minutes' + interval '0.1 seconds');

-- ===== ALARM: the 3 readings above that crossed a limit =====
INSERT INTO alarm (sensor_id, time, level, value, threshold)
VALUES ((SELECT sensor_id FROM sensor WHERE name = 'temp_01'), now() - interval '4 minutes', 'warning', 48.0, 45);
INSERT INTO alarm (sensor_id, time, level, value, threshold)
VALUES ((SELECT sensor_id FROM sensor WHERE name = 'temp_01'), now() - interval '2 minutes', 'alarm', 61.5, 60);
INSERT INTO alarm (sensor_id, time, level, value, threshold)
VALUES ((SELECT sensor_id FROM sensor WHERE name = 'co_01'), now() - interval '3 minutes', 'alarm', 210, 200);

-- ===== BATTERY: 5 batteries (they get battery_id 1 to 5) =====
INSERT INTO battery (chemistry, weight_kg, voltage, condition) VALUES ('NMC', 4.5, 3.7, 'ok');  -- battery 1
INSERT INTO battery (chemistry, weight_kg, voltage, condition) VALUES ('LFP', 12.3, 3.2, 'ok');  -- battery 2
INSERT INTO battery (chemistry, weight_kg, voltage, condition) VALUES ('NCA', 0.8, 3.6, 'damaged');  -- battery 3
INSERT INTO battery (chemistry, weight_kg, voltage, condition) VALUES ('LCO', 7.6, 3.9, 'ok');  -- battery 4
INSERT INTO battery (chemistry, weight_kg, voltage, condition) VALUES ('NMC', 15.1, 4.0, 'ok');  -- battery 5

-- ===== BATTERY_EVENT: the steps of each battery =====
-- received = weighed by weight_01, inspected = checked by a person (no sensor = NULL), discharged = by voltage_01
INSERT INTO battery_event (battery_id, sensor_id, time, step, result, error_code)
VALUES (1, (SELECT sensor_id FROM sensor WHERE name = 'weight_01'), now() - interval '20 minutes', 'received', 'ok', NULL);  -- battery 1: normal
INSERT INTO battery_event (battery_id, sensor_id, time, step, result, error_code)
VALUES (1, (SELECT sensor_id FROM sensor WHERE name = 'voltage_01'), now() - interval '19 minutes', 'discharged', 'ok', NULL);
INSERT INTO battery_event (battery_id, sensor_id, time, step, result, error_code)
VALUES (2, (SELECT sensor_id FROM sensor WHERE name = 'weight_01'), now() - interval '17 minutes', 'received', 'ok', NULL);  -- battery 2: voltage does not drop
INSERT INTO battery_event (battery_id, sensor_id, time, step, result, error_code)
VALUES (2, (SELECT sensor_id FROM sensor WHERE name = 'voltage_01'), now() - interval '16 minutes', 'discharged', 'error', 'VOLTAGE_HIGH');
INSERT INTO battery_event (battery_id, sensor_id, time, step, result, error_code)
VALUES (3, (SELECT sensor_id FROM sensor WHERE name = 'weight_01'), now() - interval '14 minutes', 'received', 'ok', NULL);  -- battery 3: swollen, set aside, not discharged
INSERT INTO battery_event (battery_id, sensor_id, time, step, result, error_code)
VALUES (3, NULL, now() - interval '13 minutes', 'inspected', 'rejected', 'DAMAGED');
INSERT INTO battery_event (battery_id, sensor_id, time, step, result, error_code)
VALUES (4, (SELECT sensor_id FROM sensor WHERE name = 'weight_01'), now() - interval '11 minutes', 'received', 'error', 'WEIGHT_INVALID');  -- battery 4: impossible weight
INSERT INTO battery_event (battery_id, sensor_id, time, step, result, error_code)
VALUES (5, (SELECT sensor_id FROM sensor WHERE name = 'weight_01'), now() - interval '8 minutes', 'received', 'ok', NULL);  -- battery 5: discharge takes too long
INSERT INTO battery_event (battery_id, sensor_id, time, step, result, error_code)
VALUES (5, (SELECT sensor_id FROM sensor WHERE name = 'voltage_01'), now() - interval '7 minutes', 'discharged', 'error', 'DISCHARGE_TIMEOUT');