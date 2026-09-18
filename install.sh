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

PLUGIN_ID="org.kde.plasma.metrictime"

if "$TOOL" --type Plasma/Applet -s "$PLUGIN_ID" >/dev/null 2>&1; then
    echo "Already installed, upgrading..."
    "$TOOL" --type Plasma/Applet -u "$DIR"
else
    "$TOOL" --type Plasma/Applet -i "$DIR"
fi

echo
echo "Installed. Right-click the panel -> Add Widgets... -> search \"Metric Time\"."
echo "If Plasma doesn't pick it up immediately, log out/in or run:"
echo "  plasmashell --replace &"
