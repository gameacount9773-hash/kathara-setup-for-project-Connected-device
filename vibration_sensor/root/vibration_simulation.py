
import time
import json
import random
import subprocess

BROKER_IP = "192.168.1.10"
BROKER_PORT = "1883"
MQTT_USERNAME = "iotuser"
MQTT_PASSWORD = "YourStrongPassword"

MQTT_TOPIC = "voltcycle/sorting/vibration/01"


def simulate_vibration():
    # Warning: Baseline + 0.7, Alarm: >= 4.5
    baseline = 1.0

    val = random.choices(
        [
            round(random.uniform(0.5, 1.5), 1),
            round(random.uniform(baseline + 0.7, 3.5), 1),
            round(random.uniform(4.5, 8.0), 1)
        ],
        weights=[0.9, 0.08, 0.02]
    )[0]

    return {
        "sensor_id": "vibration_01",
        "value": val,
        "unit": "mm/s RMS"
    }


while True:
    payload_str = json.dumps(simulate_vibration())

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
