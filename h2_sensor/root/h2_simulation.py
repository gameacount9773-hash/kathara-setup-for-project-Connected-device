import json
import random
import subprocess
import time

BROKER_IP = "192.168.1.10"
MQTT_TOPIC = "voltcycle/safety/gas/02"


def simulate_h2():
    # 模擬氫氣濃度 (% LEL)：90% 正常範圍，10% 偶發異常偏高方便測試告警
    val = random.choices(
        [
            round(random.uniform(0.0, 1.5), 2),
            round(random.uniform(4.5, 10.0), 2),
        ],
        weights=[0.9, 0.1],
    )[0]
    return {"sensor_id": "h2_01", "value": val, "unit": "% LEL"}


while True:
    payload_str = json.dumps(simulate_h2())
    subprocess.run(
        ["mosquitto_pub", "-h", BROKER_IP, "-t", MQTT_TOPIC, "-m", payload_str],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    print(f"Sent: {payload_str}")
    time.sleep(2)