#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

mkdir -p ~/.local/bin
install -m 755 bin/omarchy-session-save bin/omarchy-session-restore bin/omarchy-session-restore-agents ~/.local/bin/

# Install the boot hook the official way when available
if command -v omarchy-hook-install &>/dev/null; then
  omarchy-hook-install post-boot hooks/post-boot.d/10-session-restore
else
  mkdir -p ~/.config/omarchy/hooks/post-boot.d
  install -m 755 hooks/post-boot.d/10-session-restore ~/.config/omarchy/hooks/post-boot.d/
fi

echo "Installed:"
echo "  ~/.local/bin/omarchy-session-save"
echo "  ~/.local/bin/omarchy-session-restore"
echo "  ~/.local/bin/omarchy-session-restore-agents"
echo "  ~/.config/omarchy/hooks/post-boot.d/10-session-restore"
echo
echo "Optional: merge extensions/omarchy-menu-snippet.jsonc into"
echo "~/.config/omarchy/extensions/omarchy-menu.jsonc for menu integration,"
echo "then run: omarchy menu refresh"
