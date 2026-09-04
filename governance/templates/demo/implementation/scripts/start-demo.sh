#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
implementation_dir="$(cd "$script_dir/.." && pwd)"
cd "$implementation_dir"

if [ ! -f .env ]; then
  cp .env.example .env
  echo "Created local .env from .env.example"
fi

set -a
# shellcheck disable=SC1091
. ./.env
set +a

docker compose up --build -d
bash scripts/healthcheck.sh

echo "Demo is ready at http://localhost:${FRONTEND_PORT:-3100}"
