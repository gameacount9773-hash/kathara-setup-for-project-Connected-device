FROM kathara/base

ENV DEBIAN_FRONTEND=noninteractive

# 僅保留 IoT 感測網路需要的核心套件：MQTT、Python、網路工具與資安用的 iptables
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    mosquitto mosquitto-clients \
    python3 iputils-ping iptables curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*