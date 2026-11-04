# Indicators (defanged: do not visit)

Replace `[.]` with `.` only inside a blocklist or analysis tool, never in a browser.

## Network
| Indicator | Role |
|---|---|
| `ipconfig-ten[.]vercel[.]app` | Receives stolen environment variables and returns code that the server runs |
| `apigoogle-ashen[.]vercel[.]app` | Hosts scripts piped into a shell on folder open (`/api/settings/windows`, `/linux`, `/mac`) |
| `neonvalut[.]xyz` | Wallet-login lure (misspelled "vault"); **unverified** |
| `mbank-poker[.]netlify[.]app` | `/api/*` proxy target in the client's `_redirects`; **unverified** |
| `0g-rollplay[.]netlify[.]app` | Referenced in the sitemap; **unverified** |
| HTTP header `x-app-request: ip-check` | Disguises the exfiltration request |

A similarly named domain, `vscode-ip-address-checking-ten[.]vercel[.]app`, is listed on ThreatFox (IOC 1802037) as payload delivery. A relationship to this sample is unconfirmed.

## Account and repository
- GitHub account: `ritualwork`; repository `zetamvp`; single commit `cbcf328` ("coin 2026-06-14 update interface")

## Code patterns
- `.vscode/tasks.json` with `"runOn": "folderOpen"` and a download piped into `cmd`, `bash` or `sh`
- `.vscode/settings.json` with `files.exclude` hiding `**/.vscode` and `editor.wordWrap` set to `off`
- ~580 spaces before `"command"` on the malicious lines
- `package.json` `prepare` script that starts `node server`
- `validateApiKey()` called at load; `atob()` of a hardcoded string; `...process.env` in an outbound POST; `new Function("require", response.data)`

## Social engineering
- A recruiter profile presenting as a "partner" of a real company, with a headline typo and a duplicated greeting in the first message
- A job description hosted in a Google Doc instead of a company careers page
- A scheduling account named for the impersonated company: `calendly[.]com/ritual-meet`
- An interview that ends in a request to clone and run a poker app, share your screen, or log in to a wallet

## Not included on purpose
Credential values, personal data about any person, and the malicious files themselves.
