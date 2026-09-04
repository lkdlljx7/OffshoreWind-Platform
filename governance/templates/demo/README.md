# Demo 名称

## 产品资料

- 最终 PRD：进入 `approved` 前补充 `product/requirements/<artifact-id>.md`
- 业务流程：如适用，在此补充链接。
- 产品决策：如适用，在此补充链接。

## 业务目标

说明本 Demo 需要验证的业务闭环和评审结论。

## 快速启动

前置条件：Docker Desktop 或其他支持 Docker Compose 的环境。

首次复制模板后，请将 `.env.example` 中的 `COMPOSE_PROJECT_NAME` 改为当前成果标识，避免不同 Demo 的容器和数据卷发生冲突。端口被占用时，也可以在本地 `.env` 中调整。

```bash
cd implementation
cp .env.example .env
docker compose up --build
```

打开 `http://localhost:3100`。后端健康检查位于 `http://localhost:3100/api/health`。

## 演示账号

在此记录虚构的本地演示账号。不要提交真实账号或密码。

## 标准演示路径

1. 在此填写入口和初始状态。
2. 在此填写核心操作。
3. 在此填写预期结果。

## 数据重置

以下命令会删除当前 Demo 的本地数据库卷并恢复标准演示数据：

```bash
cd implementation
./scripts/reset-demo.sh --confirm
```

## 停止 Demo

```bash
cd implementation
./scripts/stop-demo.sh
```

## 已知限制

- 在此记录尚未实现或仅使用 Mock 验证的能力。
