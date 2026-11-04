#!/usr/bin/env bash
# detect.sh - read-only scanner for trojanized-repo patterns (fake-interview malware).
# It only READS text files with grep. It never executes, installs or opens anything it scans.
# Usage: ./detect.sh /path/to/repo   (use a disposable VM if the repo is untrusted)
set -u
ROOT="${1:-.}"
[ -d "$ROOT" ] || { echo "Not a directory: $ROOT" >&2; exit 64; }
crit=0; high=0; med=0
EX=(--exclude-dir=node_modules --exclude-dir=.git --exclude-dir=build --exclude-dir=dist)
JS=(--include=*.js --include=*.mjs --include=*.cjs --include=*.ts --include=*.jsx --include=*.tsx)
TXT=("${JS[@]}" --include=*.json --include=*.sh --include=*.bat --include=*.cmd --include=*.ps1 --include=*.yml --include=*.yaml)

scan() {  # scan LEVEL "description" "regex" [extra grep args...]
  local level="$1" desc="$2" re="$3"; shift 3
  local out
  out=$(grep -rnIE "${EX[@]}" "$@" -e "$re" "$ROOT" 2>/dev/null | cut -d: -f1,2 | head -25)
  if [ -n "$out" ]; then
    echo; echo "[$level] $desc"; echo "$out" | sed 's/^/    /'
    case "$level" in CRITICAL) crit=$((crit+1));; HIGH) high=$((high+1));; *) med=$((med+1));; esac
  fi
}

scan CRITICAL "Download piped straight into a shell" '(curl|wget|iwr|Invoke-WebRequest)[^|]*\|[[:space:]]*(bash|sh|cmd|powershell|pwsh|iex)\b' "${TXT[@]}"
scan HIGH "Editor task set to run on folder open" '"runOn"[[:space:]]*:[[:space:]]*"folderOpen"' --include=tasks.json
scan HIGH "Long whitespace run (content hidden off-screen)" ' {120,}[^ ]' "${JS[@]}" --include=*.json
scan HIGH "All environment variables sent or serialized" '\.\.\.[[:space:]]*process\.env|stringify\([[:space:]]*process\.env' "${JS[@]}"
scan HIGH "Code built from data at runtime (new Function / eval)" 'new[[:space:]]+Function[[:space:]]*\(|(^|[^A-Za-z_.])eval[[:space:]]*\(' "${JS[@]}"
scan MEDIUM "Base64-decoded string (possible hidden URL or payload)" '\batob[[:space:]]*\(|Buffer\.from\([^)]*base64' "${JS[@]}"
scan MEDIUM "Install-time script hook in package.json" '"(preinstall|install|postinstall|prepare|prepack)"[[:space:]]*:' --include=package.json
scan MEDIUM "Editor settings that hide .vscode or turn off word wrap" '"\*\*/\.vscode"|"editor\.wordWrap"[[:space:]]*:[[:space:]]*"off"' --include=settings.json

envs=$(find "$ROOT" -type d \( -name node_modules -o -name .git \) -prune -o -type f \( -name '.env' -o -name '.env.*' \) ! -name '.env.example' ! -name '.env.sample' -print 2>/dev/null | head -10)
if [ -n "$envs" ]; then
  echo; echo "[MEDIUM] Committed .env file (never open or copy its values)"; echo "$envs" | sed 's/^/    /'; med=$((med+1))
fi

echo; echo "Summary: critical=$crit high=$high medium=$med (categories with hits, not line counts)"
if [ $((crit+high)) -gt 0 ]; then echo "Treat this repo as hostile. Do not run, install, or open it in VS Code."; exit 2; fi
if [ $med -gt 0 ]; then echo "Review the flagged items manually before running anything."; exit 1; fi
echo "No known patterns found. That does not prove the repo is safe."; exit 0
