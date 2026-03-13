#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-inventory}"

echo "Deploying Enterprise DevOps Inventory Platform to namespace: ${NAMESPACE}"
kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -
kubectl -n "${NAMESPACE}" apply -f kubernetes/postgres.yaml
kubectl -n "${NAMESPACE}" apply -f kubernetes/deployment.yaml
kubectl -n "${NAMESPACE}" apply -f kubernetes/service.yaml
kubectl -n "${NAMESPACE}" apply -f kubernetes/hpa.yaml

echo "Deployment finished."
