import time
import json
import random
import subprocess

BROKER_IP = "192.168.1.10"
MQTT_TOPIC = "voltcycle/sorting/vision/01"

BATTERY_TYPES = ["AA", "AAA", "C", "D", "18650", "Pouch"]
CONDITIONS = ["Good", "Dented", "Swollen", "Leaking"]

def process_vision_data():
    """模擬 Edge PC 處理完相機原始影像後的辨識結果"""
    return {
        "sensor_id": "vision_01",
        "battery_type": random.choice(BATTERY_TYPES),
        "condition": random.choices(CONDITIONS, weights=[0.85, 0.05, 0.05, 0.05])[0],
        "confidence_score": round(random.uniform(88.0, 99.9), 2)
    }

def publish_mqtt(payload):
    payload_str = json.dumps(payload)
    command = [
        "mosquitto_pub",
        "-h", BROKER_IP,
        "-t", MQTT_TOPIC,
        "-m", payload_str
    ]
    try:
        subprocess.run(command, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        print(f"[Vision Edge PC] Processed and Published: {payload_str}")
    except subprocess.CalledProcessError as e:
        print(f"[Vision Edge PC] Error publishing MQTT: {e}")

if __name__ == "__main__":
    print("[Vision Edge PC] Starting vision processing engine...")
    while True:
        data = process_vision_data()
        publish_mqtt(data)
        time.sleep(2)