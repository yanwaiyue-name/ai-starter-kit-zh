<#
ai-starter-kit-zh 数据校验：字段齐全 / URL 合法 / order 唯一且连续 / name 不重复 / 枚举合法
#>
[CmdletBinding()]
param([string]$DataPath)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
if (-not $DataPath) { $DataPath = Join-Path $root 'data/modules.json' }

$errors   = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]
try { $modules = @(Get-Content -LiteralPath $DataPath -Raw -Encoding UTF8 | ConvertFrom-Json) }
catch { Write-Host ("JSON 解析失败：" + $_.Exception.Message); exit 1 }

$required = @('order', 'stage', 'name', 'title', 'desc', 'url', 'repo', 'status', 'why', 'pages_url')
$allowedStatus = @('ok', 'unknown', 'dead')
$seenNames = @{}; $seenOrders = @{}
for ($i = 0; $i -lt $modules.Count; $i++) {
    $m = $modules[$i]
    $tag = "#$($i + 1) $([string]$m.name)"
    foreach ($f in $required) {
        if (-not ($m.PSObject.Properties.Name -contains $f) -or [string]::IsNullOrWhiteSpace([string]$m.$f)) {
            $errors.Add("$tag 缺必填字段：$f")
        }
    }
    foreach ($u in @('url', 'pages_url')) {
        $v = [string]$m.$u
        if ($v -and $v -notmatch '^https?://') { $errors.Add("$tag $u 格式不合法：$v") }
    }
    if ([string]$m.repo -and [string]$m.url -and -not ([string]$m.url).Contains([string]$m.repo)) {
        $warnings.Add("$tag url 与 repo 不一致，请核对")
    }
    $st = [string]$m.status
    if ($st -and $allowedStatus -notcontains $st) { $errors.Add("$tag status 非法：$st") }

    $n = [string]$m.name
    if ($n) {
        if ($seenNames.ContainsKey($n)) { $errors.Add("$tag name 重复，与 #$($seenNames[$n]) 相同") }
        else { $seenNames[$n] = $i + 1 }
    }
    $o = [int]$m.order
    if ($seenOrders.ContainsKey($o)) { $errors.Add("$tag order=$o 重复，与 #$($seenOrders[$o]) 相同") }
    else { $seenOrders[$o] = $i + 1 }
}

# order 应从 1 连续到 N，路线图才有意义
$orders = @($seenOrders.Keys | Sort-Object)
for ($k = 1; $k -le $modules.Count; $k++) {
    if ($orders -notcontains $k) { $errors.Add("order 不连续：缺 $k") }
}

Write-Host ("校验完成：{0} 个模块，错误 {1}，警告 {2}" -f $modules.Count, $errors.Count, $warnings.Count)
foreach ($w in $warnings) { Write-Host "  [warn] $w" }
foreach ($e in $errors)   { Write-Host "  [ERROR] $e" }

if ($env:GITHUB_STEP_SUMMARY) {
    $md = @("### 启动套件 数据校验", "", "模块 **$($modules.Count)** / 错误 **$($errors.Count)** / 警告 **$($warnings.Count)**")
    if ($errors.Count -gt 0) { $md += ''; $md += '```'; $md += $errors; $md += '```' }
    Add-Content -LiteralPath $env:GITHUB_STEP_SUMMARY -Value ($md -join "`n") -Encoding utf8
}
if ($errors.Count -gt 0) { exit 1 }
Write-Host '校验通过 ✅'
