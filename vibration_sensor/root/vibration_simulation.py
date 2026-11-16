import time, json, random, subprocess
BROKER_IP = "192.168.1.10"
MQTT_TOPIC = "voltcycle/sorting/vibration/01"

def simulate_vibration():
    # 正常 Baseline, Warning: Baseline + 0.7, Alarm: >= 4.5[cite: 24]
    baseline = 1.0
    val = random.choices(
        [round(random.uniform(0.5, 1.5), 1), round(random.uniform(baseline+0.7, 3.5), 1), round(random.uniform(4.5, 8.0), 1)], 
        weights=[0.9, 0.08, 0.02])[0]
    return {"sensor_id": "vib_01", "value": val, "unit": "mm/s RMS"}

while True:
    payload_str = json.dumps(simulate_vibration())
    subprocess.run(["mosquitto_pub", "-h", BROKER_IP, "-t", MQTT_TOPIC, "-m", payload_str], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    print(f"Sent: {payload_str}")
    time.sleep(10) # 頻率：10秒[cite: 24]
