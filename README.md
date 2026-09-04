# OffshoreWind Platform

面向海上风电工程建设期施工现场管理的产品原型与可运行 Demo 仓库。

本仓库把每个业务功能视为一项独立的“交付成果”。每项成果只选择一种交付形式：

- `html`：可直接打开或通过静态服务器访问的 HTML 原型。
- `demo`：包含前端、后端、数据库和演示数据的独立可运行 Demo。

HTML 原型与 Demo 是同层级的替代方案，不存在默认的先后开发关系。

## 成果台账

`deliverables/*/artifact.yaml` 是成果信息的唯一事实来源。新增成果后，应同步更新下表；后续可由自动化脚本生成该区域。

| 业务成果 | 交付类型 | 产品状态 | 版本 | 负责人 | 使用方式 |
|---|---|---|---|---|---|
| 海上站下部基础建造进度管理 | HTML | 评审中 | v1.0.0 | Shawn | [在线预览](https://lkdlljx7.github.io/OffshoreWind-Platform/offshore-station-lower-foundation-progress/) |

## 产品状态

所有成果统一使用以下生命周期：

```text
草稿 draft → 评审中 review → 已确认 approved → 已归档 archived
```

状态表示产品成熟度，不表示工程是否可运行。进入仓库的 HTML 必须可打开，Demo 必须可独立启动，包括处于 `draft` 状态的成果。

详细规则见 [成果生命周期](governance/lifecycle.md)。

## 仓库结构

```text
deliverables/  HTML 原型和可运行 Demo，同层级管理
product/       产品愿景、需求、流程和决策记录
governance/    生命周期、命名、安全、元数据规范和模板
.github/       Issue、Pull Request 和自动校验配置
```

## 新建成果

创建 HTML 原型：

```bash
cp -R governance/templates/html deliverables/<artifact-id>
```

创建可运行 Demo：

```bash
cp -R governance/templates/demo deliverables/<artifact-id>
```

复制后必须修改 `artifact.yaml` 和 `README.md`。`draft`、`review` 阶段可以暂时没有 PRD；领导评审通过后，在 `product/requirements/` 中补充最终 PRD，并在成果进入 `approved` 前确认两者一致。

## 运行 Demo

每个 Demo 都必须能够从自身目录独立启动：

```bash
cd deliverables/<artifact-id>/implementation
cp .env.example .env
docker compose up --build
```

Demo 必须同时提供停止、健康检查和数据重置脚本。完整标准见 [贡献指南](CONTRIBUTING.md)。

## 安全原则

- 仓库只允许使用脱敏演示数据。
- 禁止提交 `.env`、访问令牌、密码和真实业务数据。
- 未完成访问权限评审前，不启用 GitHub Pages 或其他公开发布。

详细要求见 [安全与数据规范](governance/security-and-data.md)。

## 在线预览

允许公开访问的 HTML 成果登记在 `governance/pages-public.txt`。合并或提交到 `main` 后，GitHub Actions 会将登记成果自动发布到 [原型中心](https://lkdlljx7.github.io/OffshoreWind-Platform/)。

只有经过明确公开确认的成果才能加入该清单；Demo 和未登记的 HTML 成果不会被发布。
