<div align="center">

# 🧰 中文 AI 玩家从 0 到 1 · 启动套件

**一个入口，把「环境 → 工具 → 网络 → 副业 → 折腾」全部串起来**

> 从零开始玩 AI：先搞定电脑环境和网络，再装对工具，最后去折腾 Agent、副业和破甲。所有内容都指向官方上游，国内网络友好。

**📖 在线读**：https://yanwaiyue-name.github.io/ai-starter-kit-zh/

[English](README.en.md) ｜ **中文**

![License](https://img.shields.io/badge/license-MIT-green)
![Status](https://img.shields.io/badge/状态-维护中-blue)
[![validate-pr](https://github.com/yanwaiyue-name/ai-starter-kit-zh/actions/workflows/validate-pr.yml/badge.svg)](https://github.com/yanwaiyue-name/ai-starter-kit-zh/actions/workflows/validate-pr.yml)

</div>

---

## 目录

- [30 秒开始](#-30-秒开始)
- [路线：六步走完](#-路线六步走完)
- [这个套件自带什么](#-这个套件自带什么)
- [同类项目](#同类项目)
- [免责](#️-免责)

---

## ⚡ 30 秒开始

**只想在线看** → 直接打开 [路线图网页](https://yanwaiyue-name.github.io/ai-starter-kit-zh/)，每张卡片都有「在线读」。

**想一次把六个模块拉到本地**（按路线顺序 clone，已存在的目录会跳过、不覆盖）：

```powershell
# Windows（Git Bash 里用 pwsh）
pwsh scripts/setup.ps1
```

```bash
# macOS / Linux / Git Bash
bash scripts/setup.sh
```

想先看看会做什么，加 `-WhatIf` / `--dry-run`；想换目标目录，传目录参数：

```powershell
pwsh scripts/setup.ps1 -TargetDir D:\ai -WhatIf
```

---

## 🗺️ 路线：六步走完

顺序不是随便排的——每一步都是下一步的前置条件：

| # | 阶段 | 你要做的事 | 为什么排在这 | 去哪 |
| --- | --- | --- | --- | --- |
| ① | 环境 | 装 Git / Python / Node / Docker，配好代理 | 没有能跑的环境，后面所有工具都装不上 | [xiaobai-to-dalao](https://github.com/yanwaiyue-name/xiaobai-to-dalao) |
| ② | 网络 | 选机场、导入订阅、排查连不上 | 多数 AI 服务在境外，先把通道打通 | [airport-nav](https://github.com/yanwaiyue-name/airport-nav) |
| ③ | 工具 | 下载并校验 AI 客户端 | 环境就绪后按架构装，避免捆绑包 | [agent-download](https://github.com/yanwaiyue-name/agent-download) |
| ④ | 折腾 Agent | 编码代理 / 破甲 / Skills 资源导航 | 有了客户端，才谈得上挑代理和 Skills | [ai-agent-hub-zh](https://github.com/yanwaiyue-name/ai-agent-hub-zh) |
| ⑤ | 搞副业 | 真实可执行的 AI 副业清单 | 工具会用了，再看哪些路子能变现 | [ai-sidehustle-zh](https://github.com/yanwaiyue-name/ai-sidehustle-zh) |
| ⑥ | 算大账 | 学生/青年的成本收益决策 | 最后算时间、钱和不可逆的选择值不值 | [students-howtolivebetter](https://github.com/yanwaiyue-name/students-howtolivebetter) |

> 本仓库只做**索引与串联**，不重复造轮子。每一段的实际内容都在上面六个仓库里。

---

## 🧩 这个套件自带什么

| 文件 | 作用 |
| --- | --- |
| `scripts/setup.ps1` / `setup.sh` | 一键按路线 clone 全部模块（Windows / Unix 双版本） |
| `scripts/validate.ps1` | 数据校验：字段、URL、order 连续性、去重 |
| `scripts/check_links.ps1` | 每周体检六个仓库是否存活（两振出局 + 异地复核） |
| `scripts/render.ps1` | 生成 [docs/index.html](docs/index.html) 路线图网页 |
| `data/modules.json` | 机器可读的模块清单 |

每周六由 GitHub Actions 跑「校验 → 体检 → 渲染 → 部署 Pages」；改动 `data/` 的 PR 会触发 `validate-pr.yml`。

---

## 同类项目

| 项目 | 规模 | 本套件与它的差异 |
| --- | --- | --- |
| [alchaincyf/hermes-agent-orange-book](https://github.com/alchaincyf/hermes-agent-orange-book) | 5k | 中文「从入门到精通」教程，但只讲单一框架；本套件是跨六个仓库的路线索引 |
| [microsoft/Web-Dev-For-Beginners](https://github.com/microsoft/Web-Dev-For-Beginners) | 97k | 体系化课程，自带内容；本套件不写教程，只串联已有项目 |
| [MunGell/awesome-for-beginners](https://github.com/MunGell/awesome-for-beginners) | 91k | 适合贡献入门的 issue 列表，不是学习路线 |
| [Shubhamsaboo/awesome-llm-apps](https://github.com/Shubhamsaboo/awesome-llm-apps) | 143k | 示例 App 合集；本套件补的是中文新手的「先装什么」顺序 |

---

## ⚠️ 免责

所有下属项目仅供个人学习与研究，请遵守所在地法律法规与所用服务的条款。本仓库不托管任何绕过授权的内容，只做索引。
