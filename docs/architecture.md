# Enterprise DevOps Inventory Platform Architecture

## Overview
The platform is a production-style DevOps portfolio project that demonstrates a complete software delivery workflow:

1. A Python FastAPI microservice exposes inventory endpoints and Prometheus metrics.
2. Docker packages the service into a portable image.
3. Jenkins builds, tests, and publishes images, then deploys to Kubernetes.
4. Kubernetes runs the API and PostgreSQL with probes, scaling, and service exposure.
5. ArgoCD provides GitOps continuous deployment from this repository.
6. Prometheus, Grafana, and Loki/Alertmanager provide observability and alerting.
7. Terraform provisions cloud foundation resources.

## Core Components
- **Application layer**: `app/inventory-api` (FastAPI + SQLAlchemy + Prometheus client)
- **Container layer**: `app/inventory-api/Dockerfile`, `docker/docker-compose.yml`
- **Orchestration layer**: `kubernetes/*.yaml`
- **CI/CD layer**: `jenkins/Jenkinsfile`
- **GitOps layer**: `argocd/application.yaml`
- **Infrastructure layer**: `terraform/*.tf`
- **Observability layer**: `monitoring/prometheus`, `monitoring/grafana`, `monitoring/alertmanager`

## Request Flow
1. Client calls Kubernetes service `inventory-api`.
2. FastAPI handles `/health`, `/items`, `/metrics`.
3. API reads/writes inventory data to PostgreSQL.
4. Prometheus scrapes `/metrics`.
5. Grafana visualizes request throughput and latency.
6. Alertmanager raises alerts when service is down or latency is high.

## CI/CD and GitOps Flow
1. Developer pushes code to Git.
2. Jenkins pipeline executes checkout, build, docker build/push, and `kubectl apply` deployment.
3. ArgoCD continuously reconciles desired Kubernetes manifests from Git.
4. Drift is automatically corrected via self-healing sync policy.
