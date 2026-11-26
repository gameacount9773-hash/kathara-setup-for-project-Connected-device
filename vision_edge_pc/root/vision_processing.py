
import time
import json
import random
import subprocess

BROKER_IP = "192.168.1.10"
BROKER_PORT = "1883"
MQTT_USERNAME = "iotuser"
MQTT_PASSWORD = "YourStrongPassword"

MQTT_TOPIC = "voltcycle/sorting/vision/01"

BATTERY_TYPES = ["AA", "AAA", "C", "D", "18650", "Pouch"]
CONDITIONS = ["Good", "Dented", "Swollen", "Leaking"]


def process_vision_data():
    """Simulate battery vision inspection results."""
    return {
        "sensor_id": "vision_01",
        "battery_type": random.choice(BATTERY_TYPES),
        "condition": random.choices(
            CONDITIONS,
            weights=[0.85, 0.05, 0.05, 0.05]
        )[0],
        "confidence_score": round(random.uniform(88.0, 99.9), 2)
    }


def publish_mqtt(payload):
    payload_str = json.dumps(payload)

    command = [
        "mosquitto_pub",
        "-h", BROKER_IP,
        "-p", BROKER_PORT,
        "-u", MQTT_USERNAME,
        "-P", MQTT_PASSWORD,
        "-t", MQTT_TOPIC,
        "-m", payload_str
    ]

    try:
        result = subprocess.run(
            command,
            capture_output=True,
            text=True
        )

        if result.returncode == 0:
            print(
                f"[Vision Edge PC] Processed and Published: {payload_str}"
            )
        else:
            print(
                f"[Vision Edge PC] MQTT Error: {result.stderr}"
            )

    except FileNotFoundError:
        print("[Vision Edge PC] Error: mosquitto_pub not found.")


if __name__ == "__main__":
    print("[Vision Edge PC] Starting vision processing engine...")

    while True:
        data = process_vision_data()
        publish_mqtt(data)
        time.sleep(2)
