#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if command -v kpackagetool6 >/dev/null 2>&1; then
    TOOL=kpackagetool6
elif command -v kpackagetool5 >/dev/null 2>&1; then
    TOOL=kpackagetool5
else
    echo "Could not find kpackagetool6 or kpackagetool5 on PATH." >&2
    echo "On CachyOS: pacman -S plasma-workspace" >&2
    exit 1
fi

echo "Using $TOOL"

PLUGIN_ID="com.github.finnianhblr.metrictime"

if "$TOOL" --type Plasma/Applet -s "$PLUGIN_ID" >/dev/null 2>&1; then
    echo "Already installed, upgrading..."
    "$TOOL" --type Plasma/Applet -u "$DIR"
else
    "$TOOL" --type Plasma/Applet -i "$DIR"
fi

# Plasma keeps the widget's QML loaded (and cached) in the running plasmashell,
# so an upgraded widget can keep showing its OLD interface until the shell is
# restarted. That looks exactly like "my new feature doesn't show up".
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/plasmashell/qmlcache"

if [[ "${1:-}" == "--restart" ]]; then
    echo "Clearing QML cache and restarting plasmashell..."
    rm -rf "$CACHE_DIR"
    nohup plasmashell --replace >/dev/null 2>&1 &
    disown || true
    echo "Done. Give the panel a couple of seconds to come back."
else
    echo
    echo "Installed. Right-click the panel -> Add Widgets... -> search \"Metric Time\"."
    echo
    echo "IMPORTANT when upgrading: restart Plasma so it loads the new version:"
    echo "  ./install.sh --restart"
    echo "(or: rm -rf $CACHE_DIR && plasmashell --replace &)"
fi
