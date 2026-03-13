# Enterprise DevOps Inventory Platform

A production-style DevOps portfolio project showcasing a complete CI/CD and cloud-native workflow for an inventory microservice.

## Tech Stack
- **App**: Python FastAPI + SQLAlchemy
- **Containerization**: Docker + Docker Compose
- **Orchestration**: Kubernetes (Deployment, Service, HPA, Postgres)
- **CI/CD**: Jenkins pipeline
- **GitOps**: ArgoCD application manifest
- **Infrastructure as Code**: Terraform (Azure resource group example)
- **Observability**: Prometheus, Grafana, Alerting rules (Loki referenced for logs)

## Repository Structure

```text
enterprise-devops-inventory
├── app/inventory-api
│   ├── main.py
│   ├── models.py
│   ├── database.py
│   ├── requirements.txt
│   └── Dockerfile
├── docker/docker-compose.yml
├── kubernetes
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── postgres.yaml
│   └── hpa.yaml
├── jenkins/Jenkinsfile
├── terraform
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── argocd/application.yaml
├── monitoring
│   ├── prometheus/prometheus.yml
│   ├── grafana/dashboard.json
│   └── alertmanager/alerts.yml
├── scripts
│   ├── deploy.sh
│   └── healthcheck.sh
├── docs/architecture.md
└── README.md
```

## API Endpoints
- `GET /health` - health status
- `GET /items` - list inventory items
- `POST /items` - create an inventory item
- `GET /metrics` - Prometheus metrics endpoint

Example payload for `POST /items`:

```json
{
  "name": "laptop",
  "quantity": 5,
  "price": 1499.99
}
```

## Quick Start

### 1) Run locally
```bash
cd app/inventory-api
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload
```

Test endpoints:
```bash
curl http://localhost:8000/health
curl http://localhost:8000/items
curl http://localhost:8000/metrics
```

### 2) Run with Docker Compose
```bash
docker compose -f docker/docker-compose.yml up --build
```

### 3) Deploy to Kubernetes
```bash
./scripts/deploy.sh
```

### 4) Provision infrastructure with Terraform
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 5) Configure ArgoCD
Apply the ArgoCD application:
```bash
kubectl apply -f argocd/application.yaml
```

## Jenkins Pipeline Stages
The Jenkinsfile includes these stages:
1. `checkout`
2. `build`
3. `docker build`
4. `docker push`
5. `deploy to Kubernetes`

## Monitoring and Logging
- Prometheus scrape config is in `monitoring/prometheus/prometheus.yml`.
- Grafana starter dashboard JSON is in `monitoring/grafana/dashboard.json`.
- Alerting rules are in `monitoring/alertmanager/alerts.yml`.
- Loki can be integrated as the log backend for Kubernetes cluster logs.

## Notes
- Replace placeholder container registry values before production use.
- For a production database, use persistent volumes instead of `emptyDir`.
- Secure secrets via Vault/Kubernetes sealed secrets for production environments.
