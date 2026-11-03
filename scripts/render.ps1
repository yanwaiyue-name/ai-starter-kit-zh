<#
ai-starter-kit-zh 渲染：从 data/modules.json 生成 docs/index.html（不联网可用）
#>
[CmdletBinding()]
param([string]$DataPath, [string]$OutPath)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
if (-not $DataPath) { $DataPath = Join-Path $root 'data/modules.json' }
if (-not $OutPath)  { $OutPath  = Join-Path $root 'docs/index.html' }

$modules = @(Get-Content -LiteralPath $DataPath -Raw -Encoding UTF8 | ConvertFrom-Json | Sort-Object { [int]$_.order })

function Html-Escape($s) { ($s -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;' -replace '"', '&quot;') }

$rows = New-Object System.Collections.Generic.List[string]
foreach ($m in $modules) {
    $badge = switch ([string]$m.status) {
        'ok'     { '<span class="ok">✅ 存活</span>' }
        'dead'   { '<span class="dead">❌ 失效</span>' }
        default  { '<span class="unk">⚠️ 未验证</span>' }
    }
    $rows.Add(@"
    <tr>
      <td class="ord">$([string]$m.order)</td>
      <td><a href="$([string]$m.url)" target="_blank" rel="noopener">$(Html-Escape [string]$m.name)</a><br><span class="stage">$(Html-Escape [string]$m.stage)</span></td>
      <td><b>$(Html-Escape [string]$m.title)</b><br>$(Html-Escape [string]$m.desc)</td>
      <td>$badge</td>
    </tr>
"@)
}

$okCount = @($modules | Where-Object { [string]$_.status -eq 'ok' }).Count
$today = (Get-Date).ToUniversalTime().ToString('yyyy-MM-dd')

$html = @"
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>中文 AI 玩家从 0 到 1 · 启动套件</title>
<style>
  body { font-family: -apple-system, "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif; max-width: 1000px; margin: 2rem auto; padding: 0 1rem; color:#1a1a1a; line-height:1.6; }
  h1 { text-align:center; }
  .sub { text-align:center; color:#666; margin-bottom:1.5rem; }
  .summary { display:flex; gap:1rem; justify-content:center; margin-bottom:2rem; flex-wrap:wrap; }
  .summary div { background:#f5f5f7; border-radius:8px; padding:.6rem 1.2rem; }
  table { width:100%; border-collapse:collapse; font-size:.9rem; }
  th, td { text-align:left; padding:.6rem .7rem; border-bottom:1px solid #eee; vertical-align:top; }
  th { background:#fafafa; }
  .ord { font-size:1.4em; font-weight:bold; color:#0078d4; text-align:center; }
  .stage { color:#0078d4; font-size:.8em; }
  .ok { color:#1a7f37; } .dead { color:#cf222e; } .unk { color:#9a6700; }
  a { color:#0078d4; text-decoration:none; } a:hover { text-decoration:underline; }
  footer { margin-top:3rem; text-align:center; color:#999; font-size:.85rem; }
</style>
</head>
<body>
  <h1>🧰 中文 AI 玩家从 0 到 1 · 启动套件</h1>
  <p class="sub">环境 → 网络 → 工具 → Agent → 副业 → 算大账，一个入口串起来</p>
  <div class="summary">
    <div>模块 <b>$($modules.Count)</b></div>
    <div>存活 <b>$okCount</b></div>
    <div>更新 <b>$today</b></div>
  </div>
  <table>
    <thead><tr><th>#</th><th>模块</th><th>说明</th><th>状态</th></tr></thead>
    <tbody>
$(($rows -join "`n"))
    </tbody>
  </table>
  <footer>本页由 scripts/render.ps1 从 data/modules.json 生成 · 所有内容指向官方上游</footer>
</body>
</html>
"@

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $OutPath) | Out-Null
[System.IO.File]::WriteAllText($OutPath, $html, (New-Object System.Text.UTF8Encoding($false)))
Write-Host ("已生成：$OutPath （$($modules.Count) 个模块）")
