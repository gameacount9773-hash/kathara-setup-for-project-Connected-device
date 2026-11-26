
import time
import json
import random
import subprocess

BROKER_IP = "192.168.1.10"
BROKER_PORT = "1883"
MQTT_USERNAME = "iotuser"
MQTT_PASSWORD = "YourStrongPassword"

MQTT_TOPIC = "voltcycle/sorting/voltage/01"


def simulate_voltage():
    # Simulate voltage. Alarm threshold > 2.0 V
    val = random.choices(
        [
            round(random.uniform(1.0, 1.9), 2),
            round(random.uniform(2.1, 4.2), 2)
        ],
        weights=[0.95, 0.05]
    )[0]

    return {
        "sensor_id": "voltage_01",
        "value": val,
        "unit": "V per cell"
    }


while True:
    payload_str = json.dumps(simulate_voltage())

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
