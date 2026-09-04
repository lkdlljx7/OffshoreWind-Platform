#!/usr/bin/env bash

set -euo pipefail

if [ "${1:-}" != "--confirm" ]; then
  echo "This removes this Demo's local database volume."
  echo "Run: ./scripts/reset-demo.sh --confirm"
  exit 1
fi

script_dir="$(cd "$(dirname "$0")" && pwd)"
implementation_dir="$(cd "$script_dir/.." && pwd)"
cd "$implementation_dir"

docker compose down --volumes
bash scripts/start-demo.sh
