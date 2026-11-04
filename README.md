# ⛔ WARNING AND ALERT: MalPhish caught in the wild

> **This repository contains no malware.** It documents a malicious project that was handed to a developer during a fake job interview, with analysis, defanged indicators, a checklist and detection scripts.
> **The original project, `ritualwork/zetamvp`, is dangerous. Do not run it, install it, or open it in VS Code (or Cursor, VSCodium, Windsurf).** Opening the folder, running `npm install`, or starting the server can run attacker code on your computer.

Published for **defensive, educational and research purposes.** No credentials or third-party personal data are included.

---

## The 60-second version

A recruiter-style LinkedIn contact pushed a "AI and blockchain" project during a fake interview request. During the interview, the interviewee is sent to Github, told to clone the repo. This part is very important, attempts to access the code through the github folder or github desktop are ignored and the cloning is pushed. The GitHub account name imitates **Ritual**, a real AI/blockchain company; there is no evidence that company is involved. The company Career page clearly states No Positions Available. Public victim posts describe the same pattern: a recruiter who is a "partner" of a real company, a "hiring manager" interview, requests to share your screen, and an instruction to clone and run an app. An independent researcher has documented a sibling sample with the same lure was used in the Lazarus Fake Interview attacks seen in the Axie Infinity heist. And, in the last month (10-2026) Binance $6.3 billion heist was associated with the TraderTraitor Fake Interview. Likewise, the netosphere in the last six months reports RitualPlay Fake Interview in action. This report shows RitualPlay has morphed again into RitualWork and / or Ritual Meet.

## How the attack works (three triggers)

| Trigger | Where | What happens |
|---|---|---|
| Folder open | `.vscode/tasks.json` | Hidden tasks run on their own. One downloads a script from a lookalike "google" host and pipes it into a shell. Another runs `npm install` silently. |
| Install | `package.json` `prepare` script | `npm install` automatically starts the server in the background, which is why the install seems to hang. |
| Server start | `socket/index.js`, `controllers/auth.js` | A function with a harmless name decodes a hidden URL, sends **all environment variables** to it, then **executes whatever code the reply contains**. |

**Concealment:** commands are pushed hundreds of columns off-screen with whitespace, word wrap is switched off, the `.vscode` folder is hidden from the editor's file explorer, and functions are named `verify` and `setApiKey` to look routine. A committed `.env` full of realistic key names adds credibility, and the README's technology badges don't match the code.

## What's in this repo

| Path | Purpose |
|---|---|
| `docs/INDICATORS.md` | Defanged indicators: domains, header, account, code patterns |
| `docs/CHECKLIST.md` | One-page "before you run it" and "if you ran it" checklist |
| `detect/` | Read-only scanners (`detect.sh`, `detect.ps1`) and notes on each rule |
| `iocs/domains.txt` | Plain-text list for blocklist tools |

## Check a repo safely

```bash
bash detect/detect.sh /path/to/repo        # macOS / Linux
.\detect\detect.ps1 -Root C:\path\to\repo  # Windows PowerShell
```

The scanners only **read** text files. They never run or install anything, and they print `file:line` locations, not the suspicious commands. Exit code `2` means high-risk patterns were found. A clean result does **not** prove a repo is safe. Run them inside a disposable VM if the repo is untrusted. See `detect/README.md` for what each rule catches and its test status.

## Red flags worth teaching

- An unsolicited recruiter who wants you to **run their code**, share your screen, or log in
- Editor config, install hooks or startup code that does things the README never mentions
- Obfuscated strings (`atob`, base64) or `new Function` / `eval` on data from a server
- Environment variables sent to an outbound request
- A committed `.env` in a "company" project

## If you ran it

Assume the **whole machine** is exposed. Disconnect it. From a clean device, change passwords (email first), sign out of all sessions, rotate keys and tokens, and move any crypto to a new wallet created on a clean device. Run a full malware scan, and reinstall the OS if you want to be certain. Report it to the FBI IC3 (ic3.gov) and to the platforms hosting the attack.

## Context

The behavior is **consistent with publicly reported "Contagious Interview" activity** (see Daily Security Review, Nov 17, 2025, on NVISO research about this campaign's move to legitimate hosting). 

Reported to GitHub, Vercel, Netlify, LinkedIn and FBI IC3.

## Disclaimer

Provided as-is for defense, research and education. Do not use any part of this material to harm others. The original malicious files are **not** included here.
