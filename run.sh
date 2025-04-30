# ساخت شبکه مخصوص
docker network create observability-net || true

# اجرای Tempo روی شبکه
docker run -d --name tempo --network observability-net -p 3200:3200 -p 4317:4317 -p 4318:4318 -v $(pwd)/tempo-config.yaml:/etc/tempo.yaml grafana/tempo:latest -config.file=/etc/tempo.yaml

# اجرای Grafana روی شبکه
docker run -d --name grafana --network observability-net -p 3000:3000 grafana/grafana:latest

# اجرای FastAPI روی شبکه
docker build -t fastapi-app .
docker run -d --name fastapi-app --network observability-net -p 9002:9002 -v $(pwd):/app fastapi-app

