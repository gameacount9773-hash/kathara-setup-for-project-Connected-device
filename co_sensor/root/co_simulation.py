
import time
import json
import random
import subprocess

BROKER_IP = "192.168.1.10"
BROKER_PORT = "1883"
MQTT_USERNAME = "iotuser"
MQTT_PASSWORD = "YourStrongPassword"

MQTT_TOPIC = "voltcycle/safety/gas/01"  # CO


def simulate_co():
    # Normal range: 0-10 ppm
    # Warning: 35 ppm
    # Alarm: 200 ppm
    val = random.choices(
        [
            round(random.uniform(0, 10), 1),
            round(random.uniform(35, 100), 1),
            round(random.uniform(200, 300), 1)
        ],
        weights=[0.9, 0.08, 0.02]
    )[0]

    return {
        "sensor_id": "co_01",
        "value": val,
        "unit": "ppm"
    }


while True:
    payload_str = json.dumps(simulate_co())

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
