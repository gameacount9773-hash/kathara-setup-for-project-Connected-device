import time, json, random, subprocess
BROKER_IP = "192.168.1.10"
MQTT_TOPIC = "voltcycle/safety/temperature/01"

def simulate_temp():
    # 正常範圍 15-35, 偶爾製造大於 45 (Warning) 或 60 (Alarm) 的數值[cite: 23]
    val = random.choices(
        [round(random.uniform(15, 35), 1), round(random.uniform(45, 55), 1), round(random.uniform(60, 80), 1)], 
        weights=[0.9, 0.08, 0.02])[0]
    return {"sensor_id": "temp_01", "value": val, "unit": "°C"}

while True:
    payload_str = json.dumps(simulate_temp())
    subprocess.run(["mosquitto_pub", "-h", BROKER_IP, "-t", MQTT_TOPIC, "-m", payload_str], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    print(f"Sent: {payload_str}")
    time.sleep(1) # 頻率：1秒[cite: 23]
