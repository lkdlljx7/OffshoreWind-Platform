#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
implementation_dir="$(cd "$script_dir/.." && pwd)"
cd "$implementation_dir"

cleanup() {
  docker compose down --volumes
}

trap cleanup EXIT
bash scripts/start-demo.sh
bash scripts/healthcheck.sh
