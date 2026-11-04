# Fake-interview malware: one-page checklist

## Before you run anything from an interview
- [ ] Verify the recruiter and company through the company's official careers page, not a link in the message
- [ ] Confirm the email domain matches the real company
- [ ] Refuse "clone and run it" on your own machine; offer a code review or a hosted sandbox instead
- [ ] Refuse screen-share pressure and wallet or site logins during the interview
- [ ] Read the repo on GitHub first: `.vscode/`, `package.json` scripts (`prepare`, `postinstall`), `.devcontainer/`
- [ ] Run `detect/detect.sh` or `detect/detect.ps1` on it
- [ ] If you still need to run it: disposable VM, fake credentials, no wallet, `npm install --ignore-scripts`
- [ ] Never open an untrusted folder in VS Code or a fork of it (keep Workspace Trust on Restricted Mode)

## If you ran it
- [ ] Disconnect the device from the network
- [ ] From a clean device: change passwords (email first), sign out all sessions, rotate keys and tokens
- [ ] Move crypto to a new wallet created on a clean device
- [ ] Check persistence: scheduled tasks, Startup folder, `Run` registry keys, unfamiliar processes
- [ ] Full malware scan; reinstall the OS if you want certainty
- [ ] Preserve evidence offline (hashes, screenshots, messages) before reporting
- [ ] Report to FBI IC3 (ic3.gov), GitHub, and the hosting platforms
