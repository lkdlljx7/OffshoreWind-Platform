#!/usr/bin/env bash

set -euo pipefail

repository_root="$(cd "$(dirname "$0")/../.." && pwd)"

while IFS= read -r implementation_dir; do
  [ -n "$implementation_dir" ] || continue
  echo "Validating demo: ${implementation_dir#$repository_root/}"
  (
    cd "$implementation_dir"
    docker compose config --quiet
    bash scripts/ci-smoke.sh
  )
done < <(
  ruby -r date -r yaml -r pathname -e '
    root = Pathname.new(ARGV.fetch(0))
    Dir.glob(root.join("deliverables/*/artifact.yaml")).sort.each do |file|
      data = YAML.safe_load(File.read(file), permitted_classes: [Date], aliases: false)
      puts Pathname.new(file).dirname.join("implementation") if data["deliverable_type"] == "demo"
    end
  ' "$repository_root"
)
