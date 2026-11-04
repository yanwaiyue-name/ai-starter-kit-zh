#!/usr/bin/env bash
# ai-starter-kit-zh 一键启动（macOS / Linux / Git Bash）
#
# 按 data/modules.json 的 order 顺序，把全部模块 clone 到同级目录。
# 已存在的目录跳过，不覆盖、不删任何东西。
#
# 用法：
#   bash scripts/setup.sh                 # clone 到本仓库上级目录
#   bash scripts/setup.sh /path/to/dir   # 指定目标目录
#   bash scripts/setup.sh --dry-run      # 只打印会做什么

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DATA="$ROOT/data/modules.json"
TARGET="$(cd "$ROOT/.." && pwd)"
DRY=0

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY=1 ;;
    *) TARGET="$arg" ;;
  esac
done

if ! command -v jq >/dev/null 2>&1; then
  echo "需要 jq（读取 data/modules.json）。安装：winget install jqlang.jq / brew install jq" >&2
  exit 1
fi

mkdir -p "$TARGET"
done_n=0; skip_n=0; fail_n=0

while IFS=$'\t' read -r order name url stage; do
  dest="$TARGET/$name"
  label="$(printf '%s. %-28s' "$order" "$name")"
  if [ -d "$dest" ]; then
    echo "$label 已存在，跳过（不会覆盖）"
    skip_n=$((skip_n + 1))
    continue
  fi
  if [ "$DRY" -eq 1 ]; then
    echo "[dry-run] $label -> git clone --depth 1 $url $dest"
    continue
  fi
  if git clone --depth 1 "$url" "$dest" >/dev/null 2>&1; then
    echo "$label ✅ 已 clone"
    done_n=$((done_n + 1))
  else
    echo "$label ❌ clone 失败"
    fail_n=$((fail_n + 1))
  fi
done < <(jq -r '. | sort_by(.order)[] | [.order, .name, .url, .stage] | @tsv' "$DATA")

echo ""
echo "启动完成：新 clone $done_n，已存在跳过 $skip_n，失败 $fail_n"
echo "目录：$TARGET"
echo ""
echo "下一步按路线走："
jq -r '. | sort_by(.order)[] | "  \(.order). \(.name) -> \(.stage)"' "$DATA"

[ "$fail_n" -eq 0 ]
