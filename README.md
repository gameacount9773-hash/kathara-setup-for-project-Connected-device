Note for how to start    20/11/2026 Cheng-Ruei
1. BEFORE YOU START

- Keep the project in a local folder (e.g., C:\projects\...). Do NOT put it inside OneDrive-synced folders (like Documents or Desktop) to avoid database I/O locks.

- Clear any old Kathara instances to free up port 1883:

  kathara lclean
  docker compose down



2. START SERVICES

- Start TimescaleDB, n8n, and Grafana:

  docker compose up -d



- Start Kathara network simulation:

  kathara lstart

  (Use "kathara lclean" to stop and clean up Kathara nodes.)



3. LOGIN CREDENTIALS



[n8n]

- URL:      http://localhost:5678

- Email:    admin@local.test

- Password: Admin1234



[Grafana]

- URL:      http://localhost:3000

- Username: admin

- Password: admin



[TimescaleDB / PostgreSQL]

- Host:     timescaledb (or localhost:5432 from host)

- Database: factory_db

- Admin:    postgres / 1234

- Writer:   gateway_writer / Gateway-Write-26



4. N8N CREDENTIALS SETUP

After importing flow.json, verify/fill these two credentials in n8n and click Save:

- MQTT account:

  Host: host.docker.internal | Port: 1883 | Clean Session: On

- Postgres account:

  Host: timescaledb | Database: factory_db | Port: 5432

  User: gateway_writer | Password: Gateway-Write-26



5. USEFUL COMMANDS

- Manually apply init.sql (PowerShell):

  Get-Content .\shared\init.sql -Raw | docker exec -i iot_database psql -U postgres -d factory_db



- Full reset (deletes local data):

  docker compose down --remove-orphans

  Remove-Item -Recurse -Force .\db-data, .\n8n-data, .\grafana-data -ErrorAction SilentlyContinue

  docker compose up -d