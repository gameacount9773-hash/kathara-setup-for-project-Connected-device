import time, json, random, subprocess
BROKER_IP = "192.168.1.10"
MQTT_TOPIC = "voltcycle/sorting/voltage/01"

def simulate_voltage():
    # 模擬放電時的單體電壓，Alarm > 2.0V[cite: 24]
    val = random.choices(
        [round(random.uniform(1.0, 1.9), 2), round(random.uniform(2.1, 4.2), 2)], 
        weights=[0.95, 0.05])[0]
    return {"sensor_id": "volt_01", "value": val, "unit": "V per cell"}

while True:
    payload_str = json.dumps(simulate_voltage())
    subprocess.run(["mosquitto_pub", "-h", BROKER_IP, "-t", MQTT_TOPIC, "-m", payload_str], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    print(f"Sent: {payload_str}")
    time.sleep(1) # 頻率：放電期間 1秒[cite: 24]
