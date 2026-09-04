#!/usr/bin/env bash

set -euo pipefail

if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  . ./.env
  set +a
fi

frontend_port="${FRONTEND_PORT:-3100}"
backend_port="${BACKEND_PORT:-3101}"

attempt=1
while [ "$attempt" -le 30 ]; do
  if curl --fail --silent "http://127.0.0.1:${frontend_port}/" >/dev/null \
    && curl --fail --silent "http://127.0.0.1:${backend_port}/api/health" >/dev/null \
    && docker compose exec -T database pg_isready \
      -U "${POSTGRES_USER:-demo_user}" \
      -d "${POSTGRES_DB:-offshorewind_demo}" >/dev/null; then
    echo "Frontend, backend, and database are healthy."
    exit 0
  fi

  sleep 2
  attempt=$((attempt + 1))
done

echo "Demo health check failed."
docker compose ps
exit 1
