# 贡献指南

## 基本流程

1. 从模板创建交付成果，或修改已有成果。
2. 使用 `codex/<成果标识>-<事项>` 形式的短期分支。
3. 更新 `artifact.yaml` 和成果 README；进入 `approved` 前补充最终 PRD。
4. 在本地完成结构校验和运行验证。
5. 通过 Pull Request 合并到 `main`。

## 成果标识

成果目录和 `artifact.yaml` 中的 `id` 必须一致，并使用小写英文 kebab-case，例如：

```text
progress-management
quality-inspection
vessel-scheduling
```

中文业务名称写入 `artifact.yaml` 的 `name` 字段，不用于目录名。

## HTML 成果验收

- `implementation/index.html` 存在且可以打开。
- CSS、JavaScript、图片和字体使用相对路径。
- 不依赖其他成果目录。
- 不包含真实数据、凭据或生产接口。
- README 说明评审范围、推荐分辨率和已知限制。

## Demo 成果验收

- 从 `implementation/` 目录执行 `docker compose up --build` 可以启动完整环境。
- 前端、后端和数据库均由当前 Demo 的 Compose 配置管理。
- `.env.example` 包含所需配置说明，`.env` 不进入 Git。
- 数据库迁移和标准演示数据位于成果目录内。
- `scripts/healthcheck.sh` 能验证运行状态。
- `scripts/reset-demo.sh --confirm` 能恢复标准演示数据。
- 外部系统默认使用 Mock 或可控的本地替代服务。
- 依赖、基础镜像和数据库版本明确锁定，不使用 `latest`。

## 本地校验

```bash
ruby governance/scripts/validate_artifacts.rb
```

仅校验某一类型：

```bash
ruby governance/scripts/validate_artifacts.rb --type html
ruby governance/scripts/validate_artifacts.rb --type demo
```

## 状态变更

状态变更必须修改 `artifact.yaml` 并在 Pull Request 中说明依据。

- `draft`、`review`：`product.requirement` 可省略。
- `approved`、`archived`：必须通过 `product.requirement` 关联存在的最终 PRD。
- 进入 `approved` 前，应确认最终 PRD 与原型或 Demo 的确认版本一致。
- 研发交底时，应创建对应的 `artifact/<artifact-id>/v<version>` 版本标签。
- 进入 `archived` 时，应记录最后一个已验证版本和归档原因。
