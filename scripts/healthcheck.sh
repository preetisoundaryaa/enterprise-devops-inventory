#!/usr/bin/env bash
set -euo pipefail

API_URL="${1:-http://localhost:8000/health}"

echo "Running health check against ${API_URL}"
if curl -fsS "${API_URL}" >/dev/null; then
  echo "Health check passed"
else
  echo "Health check failed"
  exit 1
fi
