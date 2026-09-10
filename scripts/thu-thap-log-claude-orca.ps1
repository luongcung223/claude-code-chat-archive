# Collect Claude Code + Orca diagnostic logs into one bundle for admin review.
# Deliberately EXCLUDES credentials, keys, cookies and vault data.
# Usage:  powershell.exe -ExecutionPolicy Bypass -File "thu-thap-log-claude-orca.ps1"

$ErrorActionPreference = 'Continue'

$stamp   = Get-Date -Format 'yyyyMMdd-HHmmss'
$root    = Join-Path $env:USERPROFILE 'claude-orca-diagnostics'
$out     = Join-Path $root $stamp
$claude  = Join-Path $env:USERPROFILE '.claude'
$orca    = Join-Path $env:APPDATA   'orca'
$prof    = Join-Path $orca 'profiles\local-default'

New-Item -ItemType Directory -Path $out -Force | Out-Null

$copied  = New-Object System.Collections.ArrayList
$skipped = New-Object System.Collections.ArrayList

function Grab {
    param([string]$Src, [string]$DstRel)
    if (-not (Test-Path -LiteralPath $Src)) {
        [void]$skipped.Add("$DstRel  (not found)")
        return
    }
    $dst    = Join-Path $out $DstRel
    $parent = Split-Path $dst -Parent
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    try {
        Copy-Item -LiteralPath $Src -Destination $dst -Recurse -Force -ErrorAction Stop
        [void]$copied.Add($DstRel)
        Write-Host "  OK    $DstRel"
    } catch {
        [void]$skipped.Add("$DstRel  (copy failed: $($_.Exception.Message))")
        Write-Host "  FAIL  $DstRel"
    }
}

Write-Host ""
Write-Host "=== Claude Code ==="
Grab (Join-Path $claude 'settings.json')                 'claude\settings.json'
Grab (Join-Path $claude 'settings.json.bak')             'claude\settings.json.bak'
Grab (Join-Path $claude 'CLAUDE.md')                     'claude\CLAUDE.md'
Grab (Join-Path $claude 'history.jsonl')                 'claude\history.jsonl'
Grab (Join-Path $claude '.last-cleanup')                 'claude\.last-cleanup'
Grab (Join-Path $claude 'projects')                      'claude\projects'
# sessions: metadata JSON only. The sibling *.key files hold live peerToken
# values used to authenticate between running sessions - never bundle them.
Get-ChildItem -LiteralPath (Join-Path $claude 'sessions') -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Extension -ne '.key' } |
    ForEach-Object { Grab $_.FullName ("claude\sessions\" + $_.Name) }
Grab (Join-Path $claude 'session-env')                   'claude\session-env'
Grab (Join-Path $claude 'shell-snapshots')               'claude\shell-snapshots'
Grab (Join-Path $claude 'hooks')                         'claude\hooks'
Grab (Join-Path $claude 'file-history')                  'claude\file-history'
Grab (Join-Path $claude 'backups')                       'claude\backups'

# settings backups with timestamped names
Get-ChildItem -LiteralPath $claude -Filter 'settings.json.bak-*' -File -ErrorAction SilentlyContinue |
    ForEach-Object { Grab $_.FullName ("claude\" + $_.Name) }

# plugin config only, not plugin payloads
Grab (Join-Path $claude 'plugins\config.json')           'claude\plugins-config.json'
Grab (Join-Path $claude 'plugins\repos.json')            'claude\plugins-repos.json'

Write-Host ""
Write-Host "=== Orca ==="
Grab (Join-Path $orca 'logs\daemon.log')                 'orca\logs\daemon.log'
Grab (Join-Path $orca 'logs\main.trace.ndjson')          'orca\logs\main.trace.ndjson'
Grab (Join-Path $orca 'orca-stats.json')                 'orca\orca-stats.json'
Grab (Join-Path $orca 'orca-runtime.json')               'orca\orca-runtime.json'
Grab (Join-Path $orca 'orca-profile-index.json')         'orca\orca-profile-index.json'
Grab (Join-Path $orca 'Preferences')                     'orca\Preferences'
Grab (Join-Path $orca 'Local State')                     'orca\Local State'
Grab (Join-Path $orca '.updaterId')                      'orca\updaterId.txt'
Grab (Join-Path $orca 'windows-acl-grant.json')          'orca\windows-acl-grant.json'
Grab (Join-Path $orca 'terminal-history')                'orca\terminal-history'
Grab (Join-Path $orca 'agent-hooks')                     'orca\agent-hooks'
Grab (Join-Path $orca 'agent-sessions')                  'orca\agent-sessions'
Grab (Join-Path $orca 'opencode-hooks')                  'orca\opencode-hooks'
Grab (Join-Path $orca 'codex-session-backfill')          'orca\codex-session-backfill'
Grab (Join-Path $orca 'daemon')                          'orca\daemon'
Grab (Join-Path $orca 'floating-workspace')              'orca\floating-workspace'
Grab (Join-Path $orca 'Crashpad')                        'orca\Crashpad'
Grab (Join-Path $orca 'orchestration.db')                'orca\orchestration.db'
Grab (Join-Path $orca 'orchestration.db-shm')            'orca\orchestration.db-shm'
Grab (Join-Path $orca 'orchestration.db-wal')            'orca\orchestration.db-wal'

Grab (Join-Path $prof 'orca-data.json')                  'orca\profile\orca-data.json'
Grab (Join-Path $prof 'active-view.json')                'orca\profile\active-view.json'
Get-ChildItem -LiteralPath $prof -Filter 'orca-data.json.bak*' -File -ErrorAction SilentlyContinue |
    ForEach-Object { Grab $_.FullName ("orca\profile\" + $_.Name) }

# ---------------------------------------------------------------
# Redact ~/.claude.json (contains account / oauth fields)
# ---------------------------------------------------------------
$src = Join-Path $env:USERPROFILE '.claude.json'
if (Test-Path -LiteralPath $src) {
    $txt = Get-Content -LiteralPath $src -Raw -Encoding UTF8
    $txt = [regex]::Replace(
        $txt,
        '("(?:[A-Za-z0-9_]*(?:[Tt]oken|[Ss]ecret|[Pp]assword|[Aa]piKey|[Kk]ey|[Cc]redential)[A-Za-z0-9_]*)"\s*:\s*)"[^"]*"',
        '$1"[REDACTED]"')
    Set-Content -LiteralPath (Join-Path $out 'claude\claude.json.redacted') -Value $txt -Encoding UTF8
    [void]$copied.Add('claude\claude.json.redacted  (token-like values masked)')
    Write-Host "  OK    claude\claude.json.redacted"
}

# ---------------------------------------------------------------
# System / version info
# ---------------------------------------------------------------
$sys = Join-Path $out 'system-info.txt'
$lines = New-Object System.Collections.ArrayList
[void]$lines.Add("Collected at      : " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'))
[void]$lines.Add("Machine           : $env:COMPUTERNAME")
[void]$lines.Add("User              : $env:USERNAME")
[void]$lines.Add("OS                : " + [System.Environment]::OSVersion.VersionString)
[void]$lines.Add("PowerShell        : " + $PSVersionTable.PSVersion.ToString())
[void]$lines.Add("CLR               : " + $PSVersionTable.CLRVersion)
[void]$lines.Add("Culture           : " + (Get-Culture).Name)
[void]$lines.Add("Console codepage  : " + (chcp))
[void]$lines.Add("")

function Ver {
    param([string]$Label, [string]$Exe, [string]$Arg)
    try {
        $v = & $Exe $Arg 2>&1 | Out-String
        [void]$lines.Add("${Label}: " + $v.Trim())
    } catch {
        [void]$lines.Add("${Label}: NOT AVAILABLE ($($_.Exception.Message))")
    }
}
Ver 'claude   ' (Join-Path $env:USERPROFILE '.local\bin\claude.exe') '--version'
Ver 'git      ' 'git.exe'  '--version'
Ver 'node     ' 'node.exe' '--version'
Ver 'python   ' 'python.exe' '--version'

[void]$lines.Add("")
[void]$lines.Add("--- Disk ---")
Get-PSDrive -PSProvider FileSystem -ErrorAction SilentlyContinue | ForEach-Object {
    if ($_.Used -ne $null) {
        [void]$lines.Add(("{0}: used {1:N1} GB, free {2:N1} GB" -f $_.Name, ($_.Used/1GB), ($_.Free/1GB)))
    }
}

[void]$lines.Add("")
[void]$lines.Add("--- Orca / Claude processes ---")
Get-Process -ErrorAction SilentlyContinue |
    Where-Object { $_.ProcessName -match 'orca|claude|codex' } |
    ForEach-Object {
        [void]$lines.Add(("{0,-20} pid={1,-8} mem={2:N0} MB  start={3}" -f `
            $_.ProcessName, $_.Id, ($_.WorkingSet64/1MB), $_.StartTime))
    }

[void]$lines.Add("")
[void]$lines.Add("--- Environment (secret-like names masked) ---")
Get-ChildItem Env: | Sort-Object Name | ForEach-Object {
    $val = $_.Value
    if ($_.Name -match '(?i)key|token|secret|password|passwd|credential|auth') { $val = '[REDACTED]' }
    [void]$lines.Add(("{0}={1}" -f $_.Name, $val))
}
Set-Content -LiteralPath $sys -Value ($lines -join "`r`n") -Encoding UTF8
Write-Host ""
Write-Host "  OK    system-info.txt"

# ---------------------------------------------------------------
# README + manifest
# ---------------------------------------------------------------
$excluded = @(
    'claude\sessions\*.key              - live peerToken for session-to-session auth',
    'orca\agent-session-authority.key   - session signing key',
    'orca\orca-e2ee-keypair.json        - end-to-end encryption keypair',
    'orca\orca-secret-protection.json   - secret protection config',
    'orca\ai-vault\                     - stored provider credentials',
    'orca\codex-pane-accounts.json      - per-pane account bindings',
    'orca\Network\  Cookies, Local Storage, Session Storage, Partitions',
    'orca\Cache\ Code Cache\ GPUCache\ blob_storage\ Dawn*Cache\',
    'claude\cache\  claude\downloads\   - transient / binaries',
    'claude\plugins\ payload (only config.json + repos.json included)'
)

$readme = @()
$readme += "CLAUDE CODE + ORCA DIAGNOSTIC BUNDLE"
$readme += "===================================="
$readme += ""
$readme += "Collected : $stamp"
$readme += "Machine   : $env:COMPUTERNAME / $env:USERNAME"
$readme += "Purpose   : admin review, debugging, system improvement"
$readme += ""
$readme += "WHAT IS NOT IN HERE (deliberately excluded - secrets):"
$excluded | ForEach-Object { $readme += "  - $_" }
$readme += ""
$readme += "PRIVACY WARNING"
$readme += "---------------"
$readme += "claude\projects\ contains FULL conversation transcripts: every prompt,"
$readme += "every file the assistant read, every command output. orca\terminal-history\"
$readme += "contains raw terminal scrollback. If any password, API key or private file"
$readme += "content was ever typed or displayed in a session, it is in those files."
$readme += "Review before sending this bundle to anyone."
$readme += ""
$readme += "CONTENTS"
$readme += "--------"
$copied | ForEach-Object { $readme += "  + $_" }
$readme += ""
$readme += "NOT FOUND / FAILED"
$readme += "------------------"
if ($skipped.Count -eq 0) { $readme += "  (none)" }
else { $skipped | ForEach-Object { $readme += "  - $_" } }
Set-Content -LiteralPath (Join-Path $out 'README.txt') -Value ($readme -join "`r`n") -Encoding UTF8

# file-level manifest
$manifest = Get-ChildItem -LiteralPath $out -Recurse -File |
    Sort-Object FullName |
    ForEach-Object {
        "{0,10:N0}  {1}  {2}" -f $_.Length, $_.LastWriteTime.ToString('yyyy-MM-dd HH:mm'), `
            $_.FullName.Substring($out.Length + 1)
    }
Set-Content -LiteralPath (Join-Path $out 'MANIFEST.txt') -Value ($manifest -join "`r`n") -Encoding UTF8

# ---------------------------------------------------------------
# Zip
# ---------------------------------------------------------------
$zip = Join-Path $root "claude-orca-logs-$stamp.zip"
if (Test-Path -LiteralPath $zip) { Remove-Item -LiteralPath $zip -Force }
Compress-Archive -Path (Join-Path $out '*') -DestinationPath $zip -CompressionLevel Optimal

$files = (Get-ChildItem -LiteralPath $out -Recurse -File).Count
$size  = (Get-ChildItem -LiteralPath $out -Recurse -File | Measure-Object Length -Sum).Sum
$zsize = (Get-Item -LiteralPath $zip).Length

Write-Host ""
Write-Host "================================================="
Write-Host ("Folder : {0}" -f $out)
Write-Host ("Zip    : {0}" -f $zip)
Write-Host ("Files  : {0}   raw {1:N1} MB   zipped {2:N1} MB" -f $files, ($size/1MB), ($zsize/1MB))
Write-Host ("Copied : {0}   Skipped: {1}" -f $copied.Count, $skipped.Count)
Write-Host "================================================="
