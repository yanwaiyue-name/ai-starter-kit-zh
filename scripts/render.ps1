<#
ai-starter-kit-zh 渲染：从 data/modules.json 生成 docs/index.html（不联网可用）

按 order 画成路线卡片，每阶段带「为什么排在这」、在线地址、体检状态。
#>
[CmdletBinding()]
param([string]$DataPath, [string]$OutPath)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
if (-not $DataPath) { $DataPath = Join-Path $root 'data/modules.json' }
if (-not $OutPath)  { $OutPath  = Join-Path $root 'docs/index.html' }

$modules = @(Get-Content -LiteralPath $DataPath -Raw -Encoding UTF8 | ConvertFrom-Json | Sort-Object { [int]$_.order })

function Html-Escape($s) {
    if ($null -eq $s) { return '' }
    ([string]$s -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;' -replace '"', '&quot;')
}

$cards = New-Object System.Collections.Generic.List[string]
foreach ($m in $modules) {
    $badge = switch ([string]$m.status) {
        'ok'     { '<span class="badge ok">✅ 存活</span>' }
        'dead'   { '<span class="badge dead">❌ 失效</span>' }
        default  { '<span class="badge unk">⚠️ 未验证</span>' }
    }
    $pages = if ($m.pages_url) {
        '<a href="' + (Html-Escape $m.pages_url) + '" target="_blank" rel="noopener">在线读 ↗</a>'
    } else { '' }
    $why = if ($m.why) { '<div class="why"><b>为什么排在这：</b>' + (Html-Escape $m.why) + '</div>' } else { '' }
    $checked = if ($m.last_checked) { '<span class="meta">最近体检 ' + (Html-Escape $m.last_checked) + '</span>' } else { '' }

    $cards.Add(@"
    <article class="card">
      <div class="ord">$([string]$m.order)</div>
      <div class="body">
        <div class="head">
          <span class="stage">$(Html-Escape $m.stage)</span>
          <a class="repo" href="$(Html-Escape $m.url)" target="_blank" rel="noopener">$(Html-Escape $m.name)</a>
          $badge
        </div>
        <h2>$(Html-Escape $m.title)</h2>
        <p class="desc">$(Html-Escape $m.desc)</p>
        $why
        <div class="links">
          <a href="$(Html-Escape $m.url)" target="_blank" rel="noopener">GitHub ↗</a>
          $pages
          $checked
        </div>
      </div>
    </article>
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
  :root { color-scheme: light dark; }
  body { font-family: -apple-system, "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif; max-width: 900px; margin: 2rem auto; padding: 0 1rem; color:#1a1a1a; line-height:1.6; }
  h1 { text-align:center; margin-bottom:.3rem; }
  .sub { text-align:center; color:#666; margin:0 0 1.2rem; }
  .summary { display:flex; gap:.8rem; justify-content:center; margin-bottom:1.5rem; flex-wrap:wrap; }
  .summary div { background:#f5f5f7; border-radius:8px; padding:.5rem 1.1rem; font-size:.9rem; }
  .howto { background:#eef6ff; border-left:4px solid #0078d4; padding:.8rem 1rem; border-radius:4px; font-size:.9rem; margin-bottom:2rem; }
  .howto code { background:#dce9f7; padding:.1rem .4rem; border-radius:4px; }
  .card { display:flex; gap:1rem; border:1px solid #e5e5e5; border-radius:10px; padding:1rem 1.2rem; margin-bottom:1rem; position:relative; }
  .card:not(:last-child)::after { content:''; position:absolute; left:2.05rem; bottom:-1rem; width:2px; height:1rem; background:#0078d4; }
  .ord { flex:0 0 2.2rem; height:2.2rem; border-radius:50%; background:#0078d4; color:#fff; display:flex; align-items:center; justify-content:center; font-size:1.15rem; font-weight:bold; }
  .body { flex:1; min-width:0; }
  .head { display:flex; gap:.6rem; align-items:center; flex-wrap:wrap; }
  .stage { color:#0078d4; font-size:.85em; font-weight:bold; }
  .repo { font-family:ui-monospace,Consolas,monospace; font-size:.85em; }
  h2 { font-size:1.05rem; margin:.35rem 0; }
  .desc { margin:.2rem 0; color:#444; font-size:.92rem; }
  .why { margin:.5rem 0; font-size:.86rem; color:#555; background:#fafafa; padding:.4rem .7rem; border-radius:4px; }
  .links { display:flex; gap:1rem; align-items:center; flex-wrap:wrap; font-size:.85rem; margin-top:.5rem; }
  .badge { font-size:.78em; padding:.1rem .45rem; border-radius:4px; white-space:nowrap; }
  .ok { color:#1a7f37; background:#dafbe1; } .dead { color:#cf222e; background:#ffebe9; } .unk { color:#9a6700; background:#fff8c5; }
  .meta { color:#888; }
  a { color:#0078d4; text-decoration:none; } a:hover { text-decoration:underline; }
  footer { margin-top:3rem; text-align:center; color:#999; font-size:.85rem; }
  @media (prefers-color-scheme: dark) {
    body { background:#0d1117; color:#e6edf3; }
    .summary div, .why { background:#161b22; color:#e6edf3; }
    .card { border-color:#30363d; }
    .howto { background:#0d2a4a; }
    .howto code { background:#17395e; }
    .desc { color:#c9d1d9; }
  }
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
  <div class="howto">
    <b>一键把六个模块拉到本地</b>（按路线顺序，已存在的目录会跳过、不覆盖）：<br>
    Windows：<code>pwsh scripts/setup.ps1</code>　·　macOS / Linux / Git Bash：<code>bash scripts/setup.sh</code><br>
    只想在线读，直接点每张卡片的「在线读」即可。
  </div>
$(($cards -join "`n"))
  <footer>本页由 scripts/render.ps1 从 data/modules.json 生成 · 所有内容指向官方上游</footer>
</body>
</html>
"@

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $OutPath) | Out-Null
[System.IO.File]::WriteAllText($OutPath, $html, (New-Object System.Text.UTF8Encoding($false)))
Write-Host ("已生成：$OutPath （$($modules.Count) 个模块）")
