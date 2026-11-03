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
  "url": "https://github.com/yanwaiyue-name/repo-name",
  "repo": "yanwaiyue-name/repo-name",
  "local_path": "../repo-name",
  "status": "ok",
  "last_checked": "2026-11-04",
  "checked_from": "seed"
}
```

## 约束

- `order` 决定路线图顺序，新增请顺延；
- `url` 必须是你自己的仓库官方地址；
- `status` 由每周体检脚本自动回写，不要手动掩盖死链。

## 提交前

```powershell
pwsh scripts/check_links.ps1        # 校验模块地址（境外判定）
pwsh scripts/render.ps1             # 重新生成 docs/index.html
```
