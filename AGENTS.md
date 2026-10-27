# Apollo 工作约定

## 项目与环境

- 本仓库是 Apollo 11 的个人开发 fork。宿主机路径为 `/home/yzc/projects/apollo`，开发容器内路径为 `/apollo_workspace`。
- 旧路径 `/home/yzc/projects/apollo-10` 已停用，不要依赖或重新创建该兼容软链接。
- 构建和 clangd 工作流以 `docs/local_development.md` 和 `scripts/local_dev.sh` 为准，修改流程时同步更新文档。
- 操作容器前检查 `.env` 和运行状态，避免假定容器名称长期不变。不要输出凭据或将本机 `.env` 提交到 Git。

## Git 与本地配置

- `origin` 为 `https://github.com/yangtzech/apollo.git`，`upstream` 为 `https://github.com/ApolloAuto/apollo.git`。执行远程操作前核对实际配置。
- 个人源码和构建修复以独立、可审查的提交保存在 fork 的 `master`。
- AEM 会重写 `WORKSPACE` 的生成区段和 `tools/package/dynamic_deps.bzl`。这两项可能长期显示修改，不得仅为清理 Git 状态直接恢复或提交本机生成内容。
- `WORKSPACE` 也含有需要版本控制的依赖定义；修改时区分生成区段和手工定义，并按开发文档维护 `WORKSPACE.source` 中对应依赖。
- 提交前检查差异，按明确路径暂存，避免把本机生成状态混入源码提交。
- 同步上游或切换分支前，先检查工作区并将生成配置保存到本地，再执行合并、重新生成和必要的构建验证。
- 不使用 `assume-unchanged` 或 `skip-worktree` 隐藏这些配置修改。

## 构建与验证

依赖安装成功后，在开发容器的仓库根目录执行：

```bash
bash scripts/local_dev.sh prepare
bash scripts/local_dev.sh build
bash scripts/local_dev.sh compile_commands
```

- `prepare` 修复旧 buildtool 留下的 proto 和 OpenSSL 路径配置；依赖准备重写配置后可能需要再次执行。
- 当前工作流面向 NVIDIA GPU，构建 `//cyber/...` 和 `//modules/...`，排除 AMD MIGraphX 后端。
- 根据硬件检查 `APOLLO_LOCAL_JOBS`、`APOLLO_LOCAL_CUDA_ARCH` 和资源限制，不盲目沿用其他机器参数。
- 构建包含测试二进制，但不执行单元测试；使用现有前端 dist，不单独打包前端源码。报告验证结果时明确这些范围。
- `compile_commands.json` 使用 `/apollo_workspace`、`/opt/apollo` 等容器路径，供同一容器中的 clangd 使用；宿主机 clangd 需要另行配置路径和依赖映射。

## 本地资源与存储

- 模型权重、构建缓存、日志、转储、`.env`、`.aem` 和 `compile_commands.json` 保留本地，不提交 Git。
- 本机专用忽略项可放在 `.git/info/exclude`；避免用过宽规则隐藏未来新增的源码或模型配置。
- 清理前确认资源用途与备份情况。不要直接运行 `git clean -fdx`、删除模型或清空大型缓存来消除变更提示。
- 活跃构建环境和 Bazel 输出使用可靠的内部 SSD。外置 USB 盘曾意外断连，主要用于保留备份和旧缓存；迁回外置盘前需重新检查连接可靠性。
- 旧 `parser.py` 已归档至 `.cache/archived-tools/parser-20261027.py`，被 Hedron 编译数据库生成流程替代，不参与构建。
- 容器名称、磁盘余量、临时日志和构建进度放在本机状态记录中；不要把一次验证结果视为后续修改仍然通过的依据。
