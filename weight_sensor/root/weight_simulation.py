import json
import random
import subprocess
import time

BROKER_IP = "192.168.1.10"
MQTT_TOPIC = "voltcycle/sorting/weight/01"


def simulate_weight():
    # 模擬正常電池重量範圍（kg），並偶爾產生偏重/異常值方便測試告警或篩選
    val = random.choices(
        [
            round(random.uniform(0.05, 1.80), 3),
            round(random.uniform(2.50, 5.00), 3),
        ],
        weights=[0.9, 0.1],
    )[0]
    return {"sensor_id": "weight_01", "value": val, "unit": "kg"}


while True:
    payload_str = json.dumps(simulate_weight())
    subprocess.run(
        ["mosquitto_pub", "-h", BROKER_IP, "-t", MQTT_TOPIC, "-m", payload_str],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    print(f"Sent: {payload_str}")
    time.sleep(1)
