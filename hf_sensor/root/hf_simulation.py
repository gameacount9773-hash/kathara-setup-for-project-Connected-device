import time, json, random, subprocess
BROKER_IP = "192.168.1.10"
MQTT_TOPIC = "voltcycle/safety/gas/03" # HF

def simulate_hf():
    # 正常範圍 0, Warning: 3, Alarm: 6[cite: 23]
    val = random.choices(
        [0.0, round(random.uniform(3, 5.9), 1), round(random.uniform(6, 15), 1)], 
        weights=[0.95, 0.03, 0.02])[0]
    return {"sensor_id": "hf_01", "value": val, "unit": "ppm"}

while True:
    payload_str = json.dumps(simulate_hf())
    subprocess.run(["mosquitto_pub", "-h", BROKER_IP, "-t", MQTT_TOPIC, "-m", payload_str], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    print(f"Sent: {payload_str}")
    time.sleep(1) # 頻率：1秒[cite: 23]
