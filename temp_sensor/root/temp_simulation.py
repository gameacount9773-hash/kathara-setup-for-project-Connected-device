
import time
import json
import random
import subprocess

BROKER_IP = "192.168.1.10"
BROKER_PORT = "1883"
MQTT_USERNAME = "iotuser"
MQTT_PASSWORD = "YourStrongPassword"

MQTT_TOPIC = "voltcycle/safety/temperature/01"


def simulate_temp():
    # Normal range: 15-35°C
    # Warning: 45-55°C
    # Alarm: 60-80°C
    val = random.choices(
        [
            round(random.uniform(15, 35), 1),
            round(random.uniform(45, 55), 1),
            round(random.uniform(60, 80), 1)
        ],
        weights=[0.9, 0.08, 0.02]
    )[0]

    return {
        "sensor_id": "temp_01",
        "value": val,
        "unit": "°C"
    }


while True:
    payload_str = json.dumps(simulate_temp())

    result = subprocess.run(
        [
            "mosquitto_pub",
            "-h", BROKER_IP,
            "-p", BROKER_PORT,
            "-u", MQTT_USERNAME,
            "-P", MQTT_PASSWORD,
            "-t", MQTT_TOPIC,
            "-m", payload_str
        ],
        capture_output=True,
        text=True
    )

    if result.returncode == 0:
        print(f"Sent: {payload_str}")
    else:
        print(f"MQTT error: {result.stderr}")

    time.sleep(1)
