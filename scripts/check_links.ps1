<#
ai-starter-kit-zh 体检：校验下属模块仓库地址存活（两振出局 + 异地复核，复用 ai-agent-hub-zh 逻辑）
#>
[CmdletBinding()]
param(
    [ValidateSet('local', 'github-actions')]
    [string]$Runner = 'local',
    [int]$TimeoutSec = 10,
    [int]$Retry = 2,
    [switch]$SecondOpinion,
    [int]$OpinionNodes = 3,
    [string]$ProxyUrl,
    [string]$DataPath
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$root = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
if (-not $DataPath) { $DataPath = Join-Path $root 'data/modules.json' }

$today = (Get-Date).ToUniversalTime().ToString('yyyy-MM-dd')
$NL = [string][char]10
$UserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36'
foreach ($v in @('HTTP_PROXY','HTTPS_PROXY','ALL_PROXY','http_proxy','https_proxy','all_proxy')) { Remove-Item -Path "env:$v" -ErrorAction SilentlyContinue }

function New-ProbeClient {
    param([int]$Timeout, [string]$Proxy)
    Add-Type -AssemblyName System.Net.Http -ErrorAction SilentlyContinue
    $h = [System.Net.Http.HttpClientHandler]::new()
    $h.AllowAutoRedirect = $true; $h.MaxAutomaticRedirections = 5
    if ($Proxy) { $h.Proxy = [System.Net.WebProxy]::new($Proxy); $h.UseProxy = $true } else { $h.UseProxy = $false }
    $c = [System.Net.Http.HttpClient]::new($h); $c.Timeout = [TimeSpan]::FromSeconds($Timeout)
    [void]$c.DefaultRequestHeaders.TryAddWithoutValidation('User-Agent', $UserAgent)
    return $c
}
function Invoke-Probe {
    param($Client, [string]$Url, [string]$Method='Head')
    try {
        $req = [System.Net.Http.HttpRequestMessage]::new([System.Net.Http.HttpMethod]::new($Method.ToUpperInvariant()), $Url)
        $resp = $Client.SendAsync($req, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).GetAwaiter().GetResult()
        $code = [int]$resp.StatusCode
        $final = if ($resp.RequestMessage.RequestUri) { $resp.RequestMessage.RequestUri.AbsoluteUri } else { $Url }
        $resp.Dispose(); return @{ Code=$code; Final=$final }
    } catch { return @{ Code=0; Final=$null } }
}
function Test-Url {
    param($Client, [string]$Url, [int]$Attempts=2)
    for ($i=1; $i -le [Math]::Max(1,$Attempts); $i++) {
        $head = Invoke-Probe -Client $Client -Url $Url -Method 'Head'
        if ($head.Code -gt 0 -and @(400,405,501) -notcontains $head.Code) { return $head }
        $get = Invoke-Probe -Client $Client -Url $Url -Method 'Get'
        if ($get.Code -gt 0) { return $get }
        if ($i -lt $Attempts) { Start-Sleep -Seconds 3 }
    }
    return @{ Code=0; Final=$null }
}
function Get-RemoteFetchVerdict {
    param([string]$Url)
    $c = $null
    try {
        $c = [System.Net.Http.HttpClient]::new(); $c.Timeout = [TimeSpan]::FromSeconds(25)
        $r = $c.GetAsync('https://r.jina.ai/'+$Url).GetAwaiter().GetResult(); $code=[int]$r.StatusCode; $r.Dispose()
        if ($code -ge 200 -and $code -lt 400) { return $true }
        if ($code -ge 400 -and $code -lt 500) { return $false }
        return $null
    } catch { return $null } finally { if ($c) { $c.Dispose() } }
}
function Get-SecondOpinion {
    param([string]$Url)
    if ((Get-RemoteFetchVerdict -Url $Url) -eq $true) { return $true }
    return $false
}

$modules = @(Get-Content -LiteralPath $DataPath -Raw -Encoding UTF8 | ConvertFrom-Json | Sort-Object { [int]$_.order })
$client = New-ProbeClient -Timeout $TimeoutSec
$proxyClient = $null
if ($ProxyUrl) { $proxyClient = New-ProbeClient -Timeout $TimeoutSec -Proxy $ProxyUrl }
$rows = New-Object System.Collections.Generic.List[string]
$ok=0; $unknown=0; $dead=0

try {
    foreach ($m in $modules) {
        $prevStatus = [string]$m.status
        $u = [string]$m.url
        $res = Test-Url -Client $client -Url $u -Attempts $Retry
        $best = $null
        if ($res.Code -gt 0) { $best = 'direct' }
        elseif ($proxyClient) { $r2 = Test-Url -Client $proxyClient -Url $u -Attempts 1; if ($r2.Code -gt 0) { $best='proxy' } }
        if ($best) {
            $m.status='ok'; $m.http_code=$res.Code
            if ($m.PSObject.Properties.Name -contains 'reachable_via') { $m.reachable_via=$best } else { $m | Add-Member -NotePropertyName 'reachable_via' -NotePropertyValue $best -Force }
        } else {
            $m.http_code=0
            if ($Runner -eq 'github-actions') {
                if ($prevStatus -eq 'ok') { $m.status='unknown' }
                elseif ($prevStatus -in @('unknown','dead')) {
                    $v='dead'
                    if ($SecondOpinion -and (Get-SecondOpinion -Url $u)) { $v='unknown' }
                    $m.status=$v
                } else { $m.status='unknown' }
            } elseif ($m.status -ne 'dead') { $m.status='unknown' }
        }
        $m.last_checked=$today; $m.checked_from=$Runner
        switch ($m.status) { 'ok'{$ok++} 'dead'{$dead++} default{$unknown++} }
        Write-Host ("{0,-26} -> {1,-8}" -f $m.name, $m.status)
        $rows.Add(("| {0} | {1} | {2} | {3} |" -f $m.name, $m.stage, $m.status, $m.url))
    }
} finally { $client.Dispose(); if ($proxyClient) { $proxyClient.Dispose() } }

[System.IO.File]::WriteAllText($DataPath, (ConvertTo-Json -InputObject $modules -Depth 8), (New-Object System.Text.UTF8Encoding($false)))
Write-Host ("体检完成：存活 $ok / 未验证 $unknown / 失效 $dead")
if ($env:GITHUB_STEP_SUMMARY) {
    $md = @("### 启动套件 模块体检（$today / $Runner）","","存活 **$ok** / 未验证 **$unknown** / 失效 **$dead**","",'| 模块 | 阶段 | 状态 | 地址 |','|---|---|---|---|') + $rows
    Add-Content -LiteralPath $env:GITHUB_STEP_SUMMARY -Value ($md -join $NL) -Encoding utf8
}
