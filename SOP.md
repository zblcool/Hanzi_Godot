# 开发与分支 SOP

这份文档记录当前 Godot 仓库的默认协作流程。目标是把日常开发、局域网试玩、线上验收和正式发布分开，不再让每一次开发提交都直接消耗 Vercel 部署额度。

## 默认分支

- `main`
  - 正式稳定主干
- `staging`
  - 线上验收分支
- `develop`
  - 日常开发分支
  - 自动化、小步提交、迁移中的未完成内容默认落在这里
- `test`
  - 历史遗留分支
  - 暂时保留为回退参考，不再作为默认开发落点

## 日常开发流程

1. 开始新工作前，先切到 `develop` 并同步远端：

```bash
git switch develop
git fetch origin
git merge --ff-only origin/develop
```

2. 如果 `main` 刚落了需要回灌的热修复，再把它带回开发线：

```bash
git merge origin/main
```

3. 本地或同一局域网预览时，优先使用：

```bash
./scripts/lan-preview.sh
```

说明：
- 这条命令默认会先重新导出 Godot Web 产物，再启动本地 HTTP 服务
- 如果只想复用现有 `build/` 目录，可以运行 `AUTO_EXPORT=0 ./scripts/lan-preview.sh`

4. 提交前，优先做最小验证：

```bash
./scripts/smoke_test_scenes.sh
./scripts/export_web.sh
```

## 推进到线上验收

当一批改动已经适合给别人在线查看时，不要直接从 `develop` 交给 Vercel，而是手动推进到 `staging`：

```bash
./scripts/promote-to-staging.sh
```

说明：
- 脚本会先拉取远端，再把 `develop` merge 进 `staging`
- 它只要求“已跟踪文件”保持干净，不会因为本地未跟踪缓存或工具目录而拒绝执行

## Vercel 约定

- 在 Vercel 项目里把 Ignored Build Step 设置为：

```bash
./scripts/vercel-ignored-build.sh
```

- 这样只有 `staging` 和 `main` 会自动部署
- `develop` 可以继续高频提交，不会再消耗线上部署额度

## 自动化约定

- 常规自动化默认在 `develop` 上工作和推送
- `staging` 保留给人工触发的线上验收
- `main` 只接已经确认稳定的结果
