# omarchy-session-restore

Session save & restore for [Omarchy](https://omarchy.org/). Save your open
windows before a reboot, get them back on your workspaces after the next boot —
including terminal working directories and, if you use herdr, your resumed AI
agent sessions.

Built for the dual-boot workflow: reboot into another OS, boot back into
Omarchy, and pick up where you left off.

## What it does

- **Save** captures every open window: its launch command (rebuilt from
  `/proc/<pid>/cmdline`), workspace, floating state, and — for terminals —
  the shell's working directory.
- **Restore** runs automatically after boot (via Omarchy's `post-boot` hook)
  and relaunches each window silently onto its saved workspace, without
  stealing focus. Terminals start back in their saved directories.
- **Agent resume** (optional): if a herdr server was running at save time, the
  restore waits for herdr to come back and restarts `claude --continue` in the
  matching pane, so your Claude Code conversation resumes by itself.
- The saved manifest is consumed after one restore, so a boot never
  double-launches anything.

## Requirements

- Omarchy with Hyprland **0.56+** (the restore dispatches through the Lua API:
  `hl.dispatch(hl.dsp.exec_cmd(...))`)
- `jq`
- Optional: herdr for agent resume

## Install

```bash
git clone https://github.com/wbarakat/omarchy-session-restore.git
cd omarchy-session-restore
./install.sh
```

For menu integration (a "Save Session" row, plus automatic save before Reboot
and Shutdown), merge `extensions/omarchy-menu-snippet.jsonc` into
`~/.config/omarchy/extensions/omarchy-menu.jsonc` and run `omarchy menu refresh`.

## Usage

```bash
omarchy-session-save              # snapshot the current session
omarchy-session-restore --dry-run # preview what a restore would launch
```

With the menu integration installed, saving is automatic: reboot or shut down
from the Omarchy menu and the session is snapshotted first. On the next boot
into Omarchy everything relaunches within a few seconds of login.

State lives in `~/.local/state/omarchy/`:

- `session.json` — the window manifest (renamed to `.restored` after use)
- `herdr-agents.json` — agent panes to resume (also consumed after use)

## Limitations

This is best-effort relaunch, not process freezing — only hibernation can
preserve actual application state across a reboot:

- Apps reopen fresh. Browsers and editors restore their own sessions if they
  are configured to; unsaved work is gone.
- Windows sharing one process (e.g. several Chromium windows or web apps)
  collapse to a single relaunch entry.
- Scratchpad/special workspaces are skipped.
- Only `claude` agents get a resume flag in herdr; other agent kinds start
  fresh.
- Saves triggered outside the menu (plain `systemctl reboot`) require running
  `omarchy-session-save` manually first.

## License

MIT
