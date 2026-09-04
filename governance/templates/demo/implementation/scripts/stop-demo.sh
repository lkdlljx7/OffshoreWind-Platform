#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
implementation_dir="$(cd "$script_dir/.." && pwd)"
cd "$implementation_dir"

docker compose down
