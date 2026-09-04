# 命名规范

## 成果目录与标识

- 使用小写英文 kebab-case。
- 目录名必须与 `artifact.yaml` 的 `id` 一致。
- 示例：`progress-management`、`quality-inspection`。

## 分支

- Codex 工作分支：`codex/<artifact-id>-<change>`。
- 其他短期分支可使用：`feature/<artifact-id>-<change>`、`fix/<artifact-id>-<change>`。
- 不长期维护按状态划分的分支。

## 标签

```text
artifact/<artifact-id>/v<major>.<minor>.<patch>
```

例如：`artifact/progress-management/v1.0.0`。

## 文件

- HTML 固定入口使用 `index.html`。
- 产品需求文件与成果标识同名。
- 产品决策使用四位顺序编号加英文主题。
- 禁止使用“最终版”“最新版”“副本”等无法稳定识别的名称。
