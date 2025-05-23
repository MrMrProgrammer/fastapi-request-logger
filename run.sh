#!/bin/bash

# حذف کانتینرهای قبلی در صورت وجود
docker rm -f tempo grafana fastapi-app 2>/dev/null || true

# حذف شبکه در صورت وجود
docker network rm observability-net 2>/dev/null || true

# ساخت شبکه مخصوص
docker network create observability-net

# اجرای Tempo روی شبکه
docker run -d --name tempo --network observability-net -p 3200:3200 -p 4317:4317 -p 4318:4318 -v $(pwd)/tempo-config.yaml:/etc/tempo.yaml grafana/tempo:latest -config.file=/etc/tempo.yaml

# اجرای Grafana روی شبکه
docker run -d --name grafana --network observability-net -p 3000:3000 grafana/grafana:latest

# اجرای FastAPI روی شبکه
docker build -t fastapi-app .
docker run -d --name fastapi-app --network observability-net -p 9002:9002 -v $(pwd):/app fastapi-app
