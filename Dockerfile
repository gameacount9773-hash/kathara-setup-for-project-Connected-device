FROM kathara/base

ENV DEBIAN_FRONTEND=noninteractive

#MQTT、Python、iptables
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    mosquitto mosquitto-clients \
    python3 iputils-ping iptables curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    #docker build -t my-iot-node .