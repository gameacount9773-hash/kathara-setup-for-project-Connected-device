
import time
import json
import random
import subprocess

BROKER_IP = "192.168.1.10"
BROKER_PORT = "1883"
MQTT_USERNAME = "iotuser"
MQTT_PASSWORD = "YourStrongPassword"

MQTT_TOPIC = "voltcycle/safety/gas/03"  # HF


def simulate_hf():
    # Normal: 0, Warning: 3–5.9, Alarm: 6–15
    val = random.choices(
        [
            0.0,
            round(random.uniform(3, 5.9), 1),
            round(random.uniform(6, 15), 1)
        ],
        weights=[0.95, 0.03, 0.02]
    )[0]

    return {
        "sensor_id": "hf_01",
        "value": val,
        "unit": "ppm"
    }


while True:
    payload_str = json.dumps(simulate_hf())

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

    time.sleep(1)  # Publishing interval: 1 second
