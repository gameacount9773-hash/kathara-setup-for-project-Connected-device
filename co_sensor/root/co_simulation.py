import time, json, random, subprocess
BROKER_IP = "192.168.1.10"
MQTT_TOPIC = "voltcycle/safety/gas/01" # CO

def simulate_co():
    # 正常範圍 0-10, Warning: 35, Alarm: 200[cite: 23]
    val = random.choices(
        [round(random.uniform(0, 10), 1), round(random.uniform(35, 100), 1), round(random.uniform(200, 300), 1)], 
        weights=[0.9, 0.08, 0.02])[0]
    return {"sensor_id": "co_01", "value": val, "unit": "ppm"}

while True:
    payload_str = json.dumps(simulate_co())
    subprocess.run(["mosquitto_pub", "-h", BROKER_IP, "-t", MQTT_TOPIC, "-m", payload_str], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    print(f"Sent: {payload_str}")
    time.sleep(1) # 頻率：1秒[cite: 23] 
