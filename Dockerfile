FROM kathara/base

ENV DEBIAN_FRONTEND=noninteractive

# 1. 安裝前置工具
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl ca-certificates gnupg wget apt-transport-https

# 2. 匯入 PostgreSQL 官方套件庫 (直接指定 bookworm，繞過 lsb_release)
RUN curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/keyrings/postgresql.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/postgresql.gpg] http://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# 3. 匯入 TimescaleDB 官方套件庫
RUN curl -s https://packagecloud.io/install/repositories/timescale/timescaledb/script.deb.sh | bash

# 4. 匯入 Grafana 官方套件庫
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://apt.grafana.com/gpg.key | gpg --dearmor > /etc/apt/keyrings/grafana.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" > /etc/apt/sources.list.d/grafana.list

# 5. 匯入 Node.js 官方套件庫
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash -

# 6. 執行總安裝 (新增 iptables 供資安組設定防火牆)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    postgresql-14 timescaledb-2-postgresql-14 \
    mosquitto mosquitto-clients \
    python3 iputils-ping iptables \
    nodejs grafana

# 7. 安裝 n8n 並清理快取 (取代 Node-RED)
RUN npm install -g --unsafe-perm n8n && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
# run: docker build -t my-iot-node .