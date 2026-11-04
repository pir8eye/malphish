# detect.ps1 - read-only scanner for trojanized-repo patterns (fake-interview malware).
# It only READS text files. It never executes, installs or opens anything it scans.
# Usage: .\detect.ps1 -Root C:\path\to\repo   (use a disposable VM if the repo is untrusted)
param([string]$Root = ".")
$ErrorActionPreference = "SilentlyContinue"
if (-not (Test-Path $Root -PathType Container)) { Write-Error "Not a directory: $Root"; exit 64 }

$skip  = '[\\/](node_modules|\.git|build|dist)[\\/]'
$files = Get-ChildItem -Path $Root -Recurse -File -Force | Where-Object { $_.FullName -notmatch $skip }
$js    = '*.js','*.mjs','*.cjs','*.ts','*.jsx','*.tsx'
$txt   = $js + '*.json','*.sh','*.bat','*.cmd','*.ps1','*.yml','*.yaml'
$counts = @{ CRITICAL = 0; HIGH = 0; MEDIUM = 0 }

function Scan($Level, $Desc, $Pattern, $Include) {
  $targets = $files | Where-Object { $n = $_.Name; ($Include | Where-Object { $n -like $_ }).Count -gt 0 }
  $hits = foreach ($f in $targets) {
    Select-String -Path $f.FullName -Pattern $Pattern | Select-Object -First 5 |
      ForEach-Object { "{0}:{1}" -f $_.Path, $_.LineNumber }
  }
  $hits = $hits | Select-Object -First 25
  if ($hits) {
    Write-Host ""; Write-Host "[$Level] $Desc"
    $hits | ForEach-Object { Write-Host "    $_" }
    $counts[$Level]++
  }
}

Scan 'CRITICAL' 'Download piped straight into a shell' '(curl|wget|iwr|Invoke-WebRequest)[^|]*\|\s*(bash|sh|cmd|powershell|pwsh|iex)\b' $txt
Scan 'HIGH' 'Editor task set to run on folder open' '"runOn"\s*:\s*"folderOpen"' @('tasks.json')
Scan 'HIGH' 'Long whitespace run (content hidden off-screen)' ' {120,}\S' ($js + '*.json')
Scan 'HIGH' 'All environment variables sent or serialized' '\.\.\.\s*process\.env|stringify\(\s*process\.env' $js
Scan 'HIGH' 'Code built from data at runtime (new Function / eval)' 'new\s+Function\s*\(|(^|[^A-Za-z_.])eval\s*\(' $js
Scan 'MEDIUM' 'Base64-decoded string (possible hidden URL or payload)' '\batob\s*\(|Buffer\.from\([^)]*base64' $js
Scan 'MEDIUM' 'Install-time script hook in package.json' '"(preinstall|install|postinstall|prepare|prepack)"\s*:' @('package.json')
Scan 'MEDIUM' 'Editor settings that hide .vscode or turn off word wrap' '"\*\*/\.vscode"|"editor\.wordWrap"\s*:\s*"off"' @('settings.json')

$envs = $files | Where-Object { $_.Name -match '^\.env(\..+)?$' -and $_.Name -notmatch 'example|sample' }
if ($envs) {
  Write-Host ""; Write-Host "[MEDIUM] Committed .env file (never open or copy its values)"
  $envs | Select-Object -First 10 | ForEach-Object { Write-Host "    $($_.FullName)" }
  $counts['MEDIUM']++
}

Write-Host ""
Write-Host ("Summary: critical={0} high={1} medium={2} (categories with hits, not line counts)" -f $counts.CRITICAL, $counts.HIGH, $counts.MEDIUM)
if (($counts.CRITICAL + $counts.HIGH) -gt 0) { Write-Host "Treat this repo as hostile. Do not run, install, or open it in VS Code."; exit 2 }
if ($counts.MEDIUM -gt 0) { Write-Host "Review the flagged items manually before running anything."; exit 1 }
Write-Host "No known patterns found. That does not prove the repo is safe."; exit 0
