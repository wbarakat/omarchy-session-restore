# Session Restore for Omarchy

Save your open windows before a reboot, get them back on your workspaces after
the next boot — including terminal working directories and, if you use herdr,
your resumed AI agent sessions.

Built for the dual-boot workflow: reboot into another OS, boot back into
Omarchy, and pick up where you left off.

## What it does

- **Save** captures every open window: its launch command (rebuilt from
  `/proc/<pid>/cmdline`), workspace, floating state, and — for terminals —
  the shell's working directory.
- **Restore** runs automatically when the Omarchy shell starts after login
  and relaunches each window silently onto its saved workspace, without
  stealing focus. Terminals start back in their saved directories.
- **Agent resume** (optional): if a herdr server was running at save time, the
  restore waits for herdr to come back and restarts `claude --continue` in the
  matching pane, so your Claude Code conversation resumes by itself.
- The saved manifest is locked and consumed after one restore, so a boot (or
  a shell restart) never double-launches anything.

## Install

```bash
omarchy plugin add https://github.com/wbarakat/omarchy-session-restore.git --enable
```

The plugin's `service` entry point runs the restore at shell startup. Saving
is manual (see Usage) until you add the optional menu integration below.

**Menu integration (recommended):** merge
`extensions/omarchy-menu-snippet.jsonc` into
`~/.config/omarchy/extensions/omarchy-menu.jsonc` and run
`omarchy menu refresh`. This adds a "Save Session" row to the System menu and
makes Reboot and Shutdown save the session automatically first. This step
edits your menu config, so it is deliberately manual — the plugin never
changes your configuration by itself.

<details>
<summary>Manual install without the plugin system</summary>

```bash
git clone https://github.com/wbarakat/omarchy-session-restore.git
cd omarchy-session-restore
./install.sh
```

This copies the scripts to `~/.local/bin` and installs a `post-boot` hook
instead of the shell service. In the menu snippet, replace the plugin paths
with `~/.local/bin/...`. Use either the plugin or the manual install, not
both.

</details>

## Usage

```bash
~/.config/omarchy/plugins/io.github.wbarakat.session-restore/bin/omarchy-session-save
# preview what a restore would launch:
~/.config/omarchy/plugins/io.github.wbarakat.session-restore/bin/omarchy-session-restore --dry-run
```

With the menu integration installed, saving is automatic: reboot or shut down
from the Omarchy menu and the session is snapshotted first. On the next boot
into Omarchy everything relaunches within a few seconds of login.

State lives in `~/.local/state/omarchy/`:

- `session.json` — the window manifest (renamed to `.restored` after use)
- `herdr-agents.json` — agent panes to resume (also consumed after use)
- `session.lock` — guards against concurrent restores

## Removal

```bash
omarchy plugin remove io.github.wbarakat.session-restore
```

Then remove the menu entries you added to
`~/.config/omarchy/extensions/omarchy-menu.jsonc` (if any) and, optionally,
the state files: `rm -f ~/.local/state/omarchy/session.json* ~/.local/state/omarchy/herdr-agents.json* ~/.local/state/omarchy/session.lock`

For a manual install, additionally delete the three `omarchy-session-*`
scripts from `~/.local/bin` and
`~/.config/omarchy/hooks/post-boot.d/10-session-restore`.

## Requirements and dependencies

- Omarchy (Quattro) with Hyprland **0.56+** — the restore dispatches through
  the Lua API: `hl.dispatch(hl.dsp.exec_cmd(...))`
- `jq` and `flock` (both ship with Omarchy / util-linux)
- Optional: herdr for agent resume; `notify-send` for save feedback

No sudo, no network access, no external downloads. The plugin only reads
`hyprctl` output and `/proc`, and writes state under `~/.local/state/omarchy/`.

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
