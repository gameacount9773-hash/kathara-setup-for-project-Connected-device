
import json
import random
import subprocess
import time

BROKER_IP = "192.168.1.10"
BROKER_PORT = "1883"
MQTT_USERNAME = "iotuser"
MQTT_PASSWORD = "YourStrongPassword"

MQTT_TOPIC = "voltcycle/sorting/magnetic/01"


def simulate_magnetic():
    # 0/1 state, matching the Magnetic unit in init.sql
    val = random.choices(
        [0, 1],
        weights=[0.85, 0.15]
    )[0]

    return {
        "sensor_id": "magnetic_01",
        "value": val,
        "unit": "0/1"
    }


while True:
    payload_str = json.dumps(simulate_magnetic())

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
