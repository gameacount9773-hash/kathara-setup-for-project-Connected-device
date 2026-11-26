
import json
import random
import subprocess
import time

BROKER_IP = "192.168.1.10"
BROKER_PORT = "1883"
MQTT_USERNAME = "iotuser"
MQTT_PASSWORD = "YourStrongPassword"

MQTT_TOPIC = "voltcycle/sorting/weight/01"


def simulate_weight():
    # Simulate normal battery weight (kg),
    # occasionally generating abnormal values for alarm testing.
    val = random.choices(
        [
            round(random.uniform(0.05, 1.80), 3),
            round(random.uniform(2.50, 5.00), 3),
        ],
        weights=[0.9, 0.1],
    )[0]

    return {
        "sensor_id": "weight_01",
        "value": val,
        "unit": "kg"
    }


while True:
    payload_str = json.dumps(simulate_weight())

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
        text=True,
    )

    if result.returncode == 0:
        print(f"Sent: {payload_str}")
    else:
        print(f"MQTT error: {result.stderr}")

    time.sleep(1)
