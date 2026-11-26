
import time
import json
import random
import subprocess

BROKER_IP = "192.168.1.10"
BROKER_PORT = "1883"
MQTT_USERNAME = "iotuser"
MQTT_PASSWORD = "YourStrongPassword"

MQTT_TOPIC = "voltcycle/safety/smoke/01"


def simulate_smoke():
    # Normal state: 0, triggered state: 1
    val = random.choices(
        [0, 1],
        weights=[0.98, 0.02]
    )[0]

    return {
        "sensor_id": "smoke_01",
        "value": val,
        "unit": "state"
    }


while True:
    payload_str = json.dumps(simulate_smoke())

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

    time.sleep(10)
