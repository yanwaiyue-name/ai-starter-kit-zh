<#
ai-starter-kit-zh 一键启动（Windows / PowerShell）

按 data/modules.json 的 order 顺序，把全部模块 clone 到同级目录。
已存在的目录默认跳过，不覆盖、不删任何东西。

用法：
  pwsh scripts/setup.ps1                      # clone 到本仓库的上级目录
  pwsh scripts/setup.ps1 -TargetDir D:\ai    # 指定目标目录
  pwsh scripts/setup.ps1 -Depth 1            # 浅克隆（默认就是）
  pwsh scripts/setup.ps1 -WhatIf             # 只打印会做什么
#>
[CmdletBinding()]
param(
    [string]$DataPath,
    [string]$TargetDir,
    [int]$Depth = 1,
    [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
if (-not $DataPath)  { $DataPath  = Join-Path $root 'data/modules.json' }
if (-not $TargetDir) { $TargetDir = Split-Path -Parent $root }

$modules = @(Get-Content -LiteralPath $DataPath -Raw -Encoding UTF8 | ConvertFrom-Json | Sort-Object { [int]$_.order })
if (-not (Test-Path -LiteralPath $TargetDir)) {
    if ($WhatIf) { Write-Host "[WhatIf] 会创建目录 $TargetDir" }
    else { New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null }
}

$done = 0; $skipped = 0; $failed = 0
foreach ($m in $modules) {
    $name = [string]$m.name
    $url  = [string]$m.url
    $dest = Join-Path $TargetDir $name
    $label = ("{0}. {1,-28}" -f $m.order, $name)

    if (Test-Path -LiteralPath $dest) {
        Write-Host "$label 已存在，跳过（不会覆盖）"
        $skipped++
        continue
    }
    $cmd = "git clone --depth $Depth $url `"$dest`""
    if ($WhatIf) { Write-Host "[WhatIf] $label -> $cmd"; continue }

    try {
        & git clone --depth $Depth $url $dest 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "git clone 退出码 $LASTEXITCODE" }
        Write-Host "$label ✅ 已 clone"
        $done++
    }
    catch {
        Write-Host "$label ❌ 失败：$($_.Exception.Message)"
        $failed++
    }
}

Write-Host ""
Write-Host ("启动完成：新 clone {0}，已存在跳过 {1}，失败 {2}" -f $done, $skipped, $failed)
Write-Host ("目录：{0}" -f (Resolve-Path $TargetDir))
Write-Host ""
Write-Host "下一步按路线走："
foreach ($m in $modules) { Write-Host ("  {0}. {1,-26} -> {2}" -f $m.order, $m.name, $m.stage) }
if ($failed -gt 0) { exit 1 }
