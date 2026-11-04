# 贡献指南（ai-starter-kit-zh）

本仓库是**索引与串联**，内容都在下属仓库里，这里只维护 `data/modules.json` 的模块清单。

## 加一个模块

在 `data/modules.json` 末尾补一条：

```json
{
  "order": 7,
  "stage": "新阶段",
  "name": "repo-name",
  "title": "一句话标题",
  "desc": "这个模块负责哪一段",
  "why": "为什么排在这个位置、前一阶段为它准备了什么",
  "url": "https://github.com/yanwaiyue-name/repo-name",
  "repo": "yanwaiyue-name/repo-name",
  "pages_url": "https://yanwaiyue-name.github.io/repo-name/",
  "status": "ok",
  "last_checked": "2026-11-04",
  "checked_from": "seed"
}
```

**不要写 `local_path`**：本地目录是可选的、随 clone 位置变化，已改为用 `pages_url` 指向在线地址。

## 约束

- `order` 决定路线图顺序，新增请顺延，且必须从 1 连续（`validate.ps1` 会检查）；
- `url` 必须是仓库官方地址，`repo` 需与 `url` 对应；
- `status` / `http_code` / `reachable_via` / `last_checked` 由体检脚本回写，不要手动改 `status` 掩盖死链；
- 新增模块后，`scripts/setup.ps1` 与 `setup.sh` 会自动把它纳入一键 clone（都从 `data/modules.json` 读取），无需改脚本。

## 提交前

```powershell
pwsh scripts/validate.ps1           # 字段 / URL / order 连续性 / 去重
pwsh scripts/render.ps1             # 重新生成 docs/index.html
bash -n scripts/setup.sh            # 校验 Unix 启动脚本语法
```

改动 `data/` 的 PR 会自动跑 `validate-pr.yml`。
