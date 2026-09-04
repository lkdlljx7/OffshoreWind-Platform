#!/usr/bin/env ruby

require "date"
require "json"
require "optparse"
require "pathname"
require "yaml"

options = { type: nil, metadata_only: false }

OptionParser.new do |parser|
  parser.banner = "Usage: validate_artifacts.rb [--type html|demo] [--metadata-only]"
  parser.on("--type TYPE", %w[html demo], "Validate only one deliverable type") do |type|
    options[:type] = type
  end
  parser.on("--metadata-only", "Validate metadata without implementation checks") do
    options[:metadata_only] = true
  end
end.parse!

root = Pathname.new(__dir__).join("../..").expand_path
deliverables_root = root.join("deliverables")
schema = JSON.parse(File.read(root.join("governance/artifact.schema.json")))
allowed_root_fields = schema.fetch("properties").keys
allowed_product_fields = schema.dig("properties", "product", "properties").keys
allowed_runtime_fields = schema.dig("properties", "runtime", "properties").keys
allowed_types = %w[html demo].freeze
allowed_statuses = %w[draft review approved archived].freeze
prd_required_statuses = %w[approved archived].freeze
required_common = %w[
  schema_version id name deliverable_type status version owner updated_at product
].freeze
required_runtime = %w[
  workdir start_command stop_command reset_command url healthcheck
].freeze
errors = []
seen_ids = {}

def relative_safe_path?(value)
  return false unless value.is_a?(String) && !value.empty?

  path = Pathname.new(value)
  !path.absolute? && !path.each_filename.include?("..")
end

metadata_files = Dir.glob(deliverables_root.join("*/artifact.yaml")).sort

metadata_files.each do |metadata_file|
  artifact_dir = Pathname.new(metadata_file).dirname
  relative_metadata = Pathname.new(metadata_file).relative_path_from(root)

  begin
    data = YAML.safe_load(
      File.read(metadata_file),
      permitted_classes: [Date],
      aliases: false
    )
  rescue StandardError => error
    errors << "#{relative_metadata}: cannot parse YAML: #{error.message}"
    next
  end

  unless data.is_a?(Hash)
    errors << "#{relative_metadata}: top-level value must be a mapping"
    next
  end

  missing = required_common.reject { |key| data.key?(key) }
  errors << "#{relative_metadata}: missing fields: #{missing.join(', ')}" unless missing.empty?
  unknown = data.keys - allowed_root_fields
  errors << "#{relative_metadata}: unknown fields: #{unknown.join(', ')}" unless unknown.empty?

  artifact_id = data["id"]
  artifact_type = data["deliverable_type"]
  status = data["status"]
  version = data["version"].to_s
  updated_at = data["updated_at"].to_s

  unless data["schema_version"] == 1
    errors << "#{relative_metadata}: schema_version must be 1"
  end

  unless artifact_id.is_a?(String) && artifact_id.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/)
    errors << "#{relative_metadata}: id must use lowercase kebab-case"
  end

  if artifact_id != artifact_dir.basename.to_s
    errors << "#{relative_metadata}: id must match its deliverable directory"
  end

  if seen_ids.key?(artifact_id)
    errors << "#{relative_metadata}: duplicate id also used by #{seen_ids[artifact_id]}"
  else
    seen_ids[artifact_id] = relative_metadata
  end

  errors << "#{relative_metadata}: invalid deliverable_type" unless allowed_types.include?(artifact_type)
  errors << "#{relative_metadata}: invalid status" unless allowed_statuses.include?(status)
  errors << "#{relative_metadata}: version must be semantic MAJOR.MINOR.PATCH" unless version.match?(/\A(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)\z/)
  begin
    Date.iso8601(updated_at)
  rescue Date::Error
    errors << "#{relative_metadata}: updated_at must be a valid YYYY-MM-DD date"
  end
  errors << "#{relative_metadata}: name must not be empty" unless data["name"].is_a?(String) && !data["name"].strip.empty?
  errors << "#{relative_metadata}: owner must not be empty" unless data["owner"].is_a?(String) && !data["owner"].strip.empty?
  errors << "#{relative_metadata}: README.md is missing" unless artifact_dir.join("README.md").file?

  product = data["product"]
  if product.is_a?(Hash)
    unknown_product = product.keys - allowed_product_fields
    errors << "#{relative_metadata}: unknown product fields: #{unknown_product.join(', ')}" unless unknown_product.empty?

    requirement = product["requirement"]
    if requirement.nil?
      if prd_required_statuses.include?(status)
        errors << "#{relative_metadata}: product.requirement is required when status is #{status}"
      end
    elsif relative_safe_path?(requirement)
      errors << "#{relative_metadata}: missing requirement file #{requirement}" unless root.join(requirement).file?
    else
      errors << "#{relative_metadata}: product.requirement must be a safe repository-relative path"
    end

    flow = product["flow"]
    if flow && !relative_safe_path?(flow)
      errors << "#{relative_metadata}: product.flow must be a safe repository-relative path"
    elsif flow && !root.join(flow).exist?
      errors << "#{relative_metadata}: missing product flow path #{flow}"
    end

    decisions = product["decisions"]
    if decisions && !decisions.is_a?(Array)
      errors << "#{relative_metadata}: product.decisions must be a list"
    elsif decisions
      decisions.each do |decision|
        if relative_safe_path?(decision)
          errors << "#{relative_metadata}: missing product decision #{decision}" unless root.join(decision).file?
        else
          errors << "#{relative_metadata}: each product decision must be a safe repository-relative path"
        end
      end
    end
  else
    errors << "#{relative_metadata}: product must be a mapping"
  end

  next if options[:metadata_only]
  next if options[:type] && artifact_type != options[:type]

  implementation = artifact_dir.join("implementation")
  errors << "#{relative_metadata}: implementation directory is missing" unless implementation.directory?

  case artifact_type
  when "html"
    entrypoint = data["entrypoint"]
    if relative_safe_path?(entrypoint)
      errors << "#{relative_metadata}: missing HTML entrypoint #{entrypoint}" unless artifact_dir.join(entrypoint).file?
    else
      errors << "#{relative_metadata}: entrypoint must be a safe deliverable-relative path"
    end
    errors << "#{relative_metadata}: HTML deliverable must not define runtime" if data.key?("runtime")
  when "demo"
    errors << "#{relative_metadata}: demo deliverable must not define entrypoint" if data.key?("entrypoint")
    runtime = data["runtime"]
    if runtime.is_a?(Hash)
      unknown_runtime = runtime.keys - allowed_runtime_fields
      errors << "#{relative_metadata}: unknown runtime fields: #{unknown_runtime.join(', ')}" unless unknown_runtime.empty?
      missing_runtime = required_runtime.reject { |key| runtime[key].is_a?(String) && !runtime[key].strip.empty? }
      errors << "#{relative_metadata}: missing runtime fields: #{missing_runtime.join(', ')}" unless missing_runtime.empty?
    else
      errors << "#{relative_metadata}: runtime must be a mapping"
    end

    required_paths = [
      "implementation/docker-compose.yml",
      "implementation/.env.example",
      "implementation/frontend",
      "implementation/backend",
      "implementation/database/migrations",
      "implementation/database/seed",
      "implementation/mock-data",
      "implementation/scripts/start-demo.sh",
      "implementation/scripts/stop-demo.sh",
      "implementation/scripts/reset-demo.sh",
      "implementation/scripts/healthcheck.sh",
      "implementation/scripts/ci-smoke.sh",
      "implementation/tests/smoke"
    ]
    required_paths.each do |relative_path|
      errors << "#{relative_metadata}: missing #{relative_path}" unless artifact_dir.join(relative_path).exist?
    end

    compose_file = artifact_dir.join("implementation/docker-compose.yml")
    if compose_file.file? && File.read(compose_file).match?(/^\s*image:\s*\S+:latest\s*$/)
      errors << "#{relative_metadata}: Docker images must not use the latest tag"
    end

    env_example = artifact_dir.join("implementation/.env.example")
    if env_example.file?
      expected_project_name = "COMPOSE_PROJECT_NAME=#{artifact_id}-demo"
      unless File.read(env_example).lines.map(&:strip).include?(expected_project_name)
        errors << "#{relative_metadata}: .env.example must define #{expected_project_name}"
      end
    end
  end
end

ignored_entries = %w[README.md].freeze
Dir.children(deliverables_root).sort.each do |entry|
  next if ignored_entries.include?(entry)
  next unless deliverables_root.join(entry).directory?
  next if deliverables_root.join(entry, "artifact.yaml").file?

  errors << "deliverables/#{entry}: artifact.yaml is missing"
end

secret_files = Dir.glob(deliverables_root.join("**/.env"))
secret_files.each do |secret_file|
  errors << "#{Pathname.new(secret_file).relative_path_from(root)}: .env must not be committed"
end

if errors.empty?
  scope = options[:type] ? "#{options[:type]} deliverables" : "all deliverables"
  puts "Validation passed for #{metadata_files.length} metadata file(s) (#{scope})."
  exit 0
end

warn "Validation failed:"
errors.each { |error| warn "- #{error}" }
exit 1
