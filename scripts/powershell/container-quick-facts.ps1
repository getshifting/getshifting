#!/usr/bin/env pwsh
$ErrorActionPreference = 'SilentlyContinue'

function Get-OsPrettyName {
    if (Test-Path '/etc/os-release') {
        $line = Get-Content '/etc/os-release' | Where-Object { $_ -like 'PRETTY_NAME=*' } | Select-Object -First 1
        if ($line) {
            return ($line -replace '^PRETTY_NAME=', '').Trim('"')
        }
    }
    return 'unknown'
}

function Get-CmdVersion {
    param(
        [string]$Name,
        [string]$Cmd,
        [string]$Fallback = 'n/a'
    )

    try {
        if (Get-Command $Name -ErrorAction Stop) {
            $out = Invoke-Expression $Cmd | Select-Object -First 1
            if ($out) { return ($out.ToString().Trim()) }
        }
    } catch {}

    return $Fallback
}

$osName = Get-OsPrettyName
$kernel = try { (uname -sr) } catch { 'unknown' }

$uptimeText = 'unknown'
if (Test-Path '/proc/uptime') {
    $uptimeSec = [double]((Get-Content '/proc/uptime' -TotalCount 1).Split(' ')[0])
    $uptime = [TimeSpan]::FromSeconds($uptimeSec)
    $uptimeText = ('{0}d {1}h {2}m' -f [int]$uptime.TotalDays, $uptime.Hours, $uptime.Minutes)
}

$hasDockerEnv = if (Test-Path '/.dockerenv') { 'yes' } else { 'no' }
$remoteContainers = if ($env:REMOTE_CONTAINERS) { $env:REMOTE_CONTAINERS } else { 'unset' }

$cpuModel = 'unknown'
$cpuCores = 'unknown'
if (Test-Path '/proc/cpuinfo') {
    $cpuModel = ((Get-Content '/proc/cpuinfo' | Select-String '^model name\s*:' | Select-Object -First 1) -replace '^model name\s*:\s*', '').Trim()
    $cpuCores = (Get-Content '/proc/cpuinfo' | Select-String '^processor\s*:' | Measure-Object).Count
}

$memLine = 'unknown'
if (Test-Path '/proc/meminfo') {
    $memTotalKb = [double]((Get-Content '/proc/meminfo' | Select-String '^MemTotal:' | ForEach-Object { ($_ -split '\s+')[1] }) | Select-Object -First 1)
    $memAvailKb = [double]((Get-Content '/proc/meminfo' | Select-String '^MemAvailable:' | ForEach-Object { ($_ -split '\s+')[1] }) | Select-Object -First 1)
    if ($memTotalKb -gt 0) {
        $totalGiB = [Math]::Round($memTotalKb / 1MB, 2)
        $availGiB = [Math]::Round($memAvailKb / 1MB, 2)
        $usedGiB = [Math]::Round($totalGiB - $availGiB, 2)
        $memLine = "$usedGiB GiB used / $totalGiB GiB total"
    }
}

$diskLine = 'unknown'
try {
    $rootFs = (df -h / | Select-Object -Last 1) -split '\s+'
    if ($rootFs.Count -ge 6) {
        $diskLine = "$($rootFs[2]) used / $($rootFs[1]) total ($($rootFs[4]) used)"
    }
} catch {}

$loadLine = 'unknown'
if (Test-Path '/proc/loadavg') {
    $parts = (Get-Content '/proc/loadavg' -TotalCount 1).Split(' ')
    if ($parts.Count -ge 3) {
        $loadLine = "$($parts[0]) $($parts[1]) $($parts[2])"
    }
}

$gitVersion = Get-CmdVersion -Name 'git' -Cmd 'git --version'
$azVersion = Get-CmdVersion -Name 'az' -Cmd 'az --version'
$pythonVersion = Get-CmdVersion -Name 'python3' -Cmd 'python3 --version'
$nodeVersion = Get-CmdVersion -Name 'node' -Cmd 'node --version'

$lines = @(
    "snapshot: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')",
    "os: $osName",
    "kernel: $kernel",
    "uptime: $uptimeText",
    "container: dockerenv=$hasDockerEnv remote_containers=$remoteContainers",
    "cpu: $cpuCores cores | $cpuModel",
    "memory: $memLine",
    "disk(/): $diskLine",
    "loadavg(1/5/15): $loadLine",
    "tools: git=[$gitVersion] | az=[$azVersion] | py=[$pythonVersion] | node=[$nodeVersion]"
)

$lines | Select-Object -First 10 | ForEach-Object { Write-Output $_ }
