#!/usr/bin/env ruby

require "cgi"
require "date"
require "fileutils"
require "pathname"
require "yaml"

root = Pathname.new(__dir__).join("../..").expand_path
output = Pathname.new(ARGV.fetch(0, root.join("_site").to_s)).expand_path
allowlist = root.join("governance/pages-public.txt")
status_names = {
  "draft" => "草稿",
  "review" => "评审中",
  "approved" => "已确认",
  "archived" => "已归档"
}.freeze

ids = File.readlines(allowlist, chomp: true)
  .map(&:strip)
  .reject { |line| line.empty? || line.start_with?("#") }

abort "No public deliverables are listed in #{allowlist.relative_path_from(root)}" if ids.empty?

FileUtils.rm_rf(output)
FileUtils.mkdir_p(output)

artifacts = ids.map do |id|
  unless id.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/)
    abort "Invalid deliverable id in public list: #{id.inspect}"
  end

  artifact_dir = root.join("deliverables", id)
  metadata_path = artifact_dir.join("artifact.yaml")
  abort "Missing metadata for public deliverable: #{id}" unless metadata_path.file?

  metadata = YAML.safe_load(
    File.read(metadata_path),
    permitted_classes: [Date],
    aliases: false
  )
  abort "Public deliverable #{id} must have deliverable_type: html" unless metadata["deliverable_type"] == "html"

  implementation = artifact_dir.join("implementation")
  entrypoint = implementation.join("index.html")
  abort "Public deliverable #{id} is missing implementation/index.html" unless entrypoint.file?

  destination = output.join(id)
  FileUtils.mkdir_p(destination)
  FileUtils.cp_r(implementation.children, destination)

  metadata
end

cards = artifacts.map do |artifact|
  id = CGI.escapeHTML(artifact.fetch("id"))
  name = CGI.escapeHTML(artifact.fetch("name"))
  version = CGI.escapeHTML(artifact.fetch("version").to_s)
  status = CGI.escapeHTML(status_names.fetch(artifact.fetch("status"), artifact.fetch("status")))

  <<~HTML
    <article class="card">
      <div class="meta"><span>#{status}</span><span>v#{version}</span></div>
      <h2>#{name}</h2>
      <a href="./#{id}/">打开原型 <span aria-hidden="true">→</span></a>
    </article>
  HTML
end.join("\n")

File.write(output.join("index.html"), <<~HTML)
  <!doctype html>
  <html lang="zh-CN">
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>OffshoreWind Platform 原型中心</title>
      <style>
        :root { color-scheme: light; font-family: Inter, "PingFang SC", "Microsoft YaHei", sans-serif; }
        * { box-sizing: border-box; }
        body { margin: 0; color: #14253d; background: #f4f7fb; }
        main { width: min(1080px, calc(100% - 40px)); margin: 0 auto; padding: 72px 0; }
        header { margin-bottom: 36px; }
        h1 { margin: 0 0 12px; font-size: clamp(30px, 5vw, 48px); letter-spacing: -0.03em; }
        header p { margin: 0; color: #607089; font-size: 17px; }
        .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 20px; }
        .card { padding: 24px; border: 1px solid #dce4ef; border-radius: 16px; background: #fff; box-shadow: 0 8px 30px rgb(31 50 81 / 7%); }
        .card h2 { min-height: 3em; margin: 18px 0 28px; font-size: 21px; line-height: 1.5; }
        .meta { display: flex; gap: 8px; }
        .meta span { padding: 5px 9px; border-radius: 999px; color: #315b91; background: #edf4fd; font-size: 13px; }
        .card a { display: inline-flex; gap: 8px; color: #0969da; font-weight: 600; text-decoration: none; }
        .card a:hover { text-decoration: underline; }
      </style>
    </head>
    <body>
      <main>
        <header>
          <h1>OffshoreWind Platform 原型中心</h1>
          <p>公开发布的产品原型，可直接在浏览器中评审。</p>
        </header>
        <section class="grid" aria-label="原型列表">
          #{cards}
        </section>
      </main>
    </body>
  </html>
HTML

puts "Built #{artifacts.length} public HTML deliverable(s) in #{output}"
