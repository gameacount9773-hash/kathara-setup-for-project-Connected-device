import json
import random
import subprocess
import time

BROKER_IP = "192.168.1.10"
MQTT_TOPIC = "voltcycle/sorting/magnetic/01"


def simulate_magnetic():
    # 0/1 狀態，對應 init.sql 中 Magnetic 單位 '0/1' 與頻率 1 秒
    val = random.choices([0, 1], weights=[0.85, 0.15])[0]
    return {"sensor_id": "magnetic_01", "value": val, "unit": "0/1"}


while True:
    payload_str = json.dumps(simulate_magnetic())
    subprocess.run(
        ["mosquitto_pub", "-h", BROKER_IP, "-t", MQTT_TOPIC, "-m", payload_str],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    print(f"Sent: {payload_str}")
    time.sleep(1)
