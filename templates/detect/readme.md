# detect: read-only scanners

`detect.sh` (Bash) and `detect.ps1` (PowerShell) look for patterns used by trojanized "interview" repos. They only **read** text files with grep or `Select-String`. They never run, install or open anything they scan, and they print `file:line` locations rather than the suspicious commands.

```bash
bash detect/detect.sh /path/to/repo
.\detect\detect.ps1 -Root C:\path\to\repo
```

Exit codes: `0` nothing found, `1` medium findings to review, `2` critical or high findings (treat the repo as hostile), `64` bad path.

## Rules

| Level | What it flags | Why | Common false positives |
|---|---|---|---|
| CRITICAL | A download (`curl`, `wget`, `iwr`) piped into `bash`, `sh`, `cmd`, `powershell` or `iex` | Runs unseen remote code | Install docs and setup scripts that use `curl ... \| bash` |
| HIGH | `"runOn": "folderOpen"` in `tasks.json` | Runs when the folder is opened in VS Code | Legitimate auto-start tasks (dev servers, linters) |
| HIGH | 120+ consecutive spaces before more text in code or JSON | Hides content off-screen | Aligned data tables, generated files |
| HIGH | `...process.env` or `stringify(process.env)` | Serializes every environment variable | Debug logging, config dumps |
| HIGH | `new Function(...)` or `eval(...)` | Runs code built at runtime | Build tools, templating libraries |
| MEDIUM | `atob(...)` or `Buffer.from(..., 'base64')` | Hidden URLs or payloads | Auth libraries, image handling |
| MEDIUM | `preinstall`/`install`/`postinstall`/`prepare`/`prepack` scripts | Runs automatically on install | Tools like Husky, native-module builds |
| MEDIUM | Settings that hide `.vscode` or turn word wrap off | Conceals files and long lines | Personal preference |
| MEDIUM | A committed `.env` file | Bait or leaked secrets | Template repos (`.env.example` is ignored) |

A hit is a reason to look closer, not proof. A clean result is not proof of safety.

## Test status

- `detect.sh`: tested on a known-bad sample (all nine categories flagged, exit 2) and on a clean folder (no findings, exit 0).
- `detect.ps1`: a direct port of `detect.sh`, **not yet tested**. Try it on a known-bad sample inside a VM before relying on it.
