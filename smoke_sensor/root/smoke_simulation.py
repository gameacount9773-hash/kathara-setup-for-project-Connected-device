import time, json, random, subprocess
BROKER_IP = "192.168.1.10"
MQTT_TOPIC = "voltcycle/safety/smoke/01"

def simulate_smoke():
    # 正常 0, 觸發為 1[cite: 23]
    val = random.choices([0, 1], weights=[0.98, 0.02])[0]
    return {"sensor_id": "smoke_01", "value": val, "unit": "state"}

while True:
    payload_str = json.dumps(simulate_smoke())
    subprocess.run(["mosquitto_pub", "-h", BROKER_IP, "-t", MQTT_TOPIC, "-m", payload_str], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    print(f"Sent: {payload_str}")
    time.sleep(10) # 頻率：Heartbeat 10秒[cite: 23]
