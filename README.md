# Metric Time (KDE Plasma)

A Plasma panel widget that shows decimal (metric) time — the KDE counterpart to
[metric-time-mac](https://github.com/FinnianHBLR/metric-time-mac).

The day is split into **10 hours of 100 minutes of 100 seconds**, so midnight is
`0:00:00 M`, noon is `5:00:00 M`, and one decimal second is 0.864 SI seconds.
The trailing `M` marks the reading as metric.

The popup also has a French-Revolutionary-style **decimal calendar** (12 months of
30 days, 5–6 epagomenal days at year's end), ported from the
[Cinnamon applet](https://github.com/Arranlr/Decimal-Time-and-Calendar-Linux-Mint-Applet).

## Install (CachyOS / any Arch-based Plasma 6 setup)

Make sure the KPackage tools are present (they ship with Plasma, so this is
usually already installed):

```bash
sudo pacman -S plasma-workspace
```

Then from this folder:

```bash
chmod +x install.sh
./install.sh
```

Right-click an empty spot on your panel → **Add Widgets…** → search
**"Metric Time"** → drag it onto the panel.

To remove it later:

```bash
kpackagetool6 --type Plasma/Applet -r com.github.finnianhblr.metrictime
```

(use `kpackagetool5` instead if your system is still on Plasma 5).

## Settings

Right-click the widget on the panel → **Configure Metric Time…**

- **Show** — hours & minutes (`5:43`), hours/minutes/seconds (`5:43:21`), or
  the raw day fraction (`.54321`)
- **Suffix** — toggle the trailing `M` marker
- **In panel** — optionally show the conventional time next to the decimal
  one right on the panel (it's always shown in the popup regardless)
- **Popup** — show or hide the decimal calendar (on by default). Today's
  decimal date stays visible either way.

Click the widget to open a popup with both the decimal and conventional time
and the raw day fraction.

## Calendar

Click the widget and the popup shows today's decimal date plus a navigable
month grid. Hovering the widget on the panel also shows the date in the tooltip.

- **Months** (Latin numeral roots): Unember, Duember, Triember, Quadember,
  Quintember, Sextember, September, October, November, December, Undecember,
  Duodecember — 30 days each, in three décades of ten.
- **Days of the décade** (Greek numeral roots): Monoday, Diday, Triday,
  Tetraday, Pentaday, Hexaday, Heptaday, Octaday, Enneaday, Decaday (rest day,
  shown in red).
- **Epagomenal days**: 5 or 6 extra days closing each year, belonging to no
  month. They appear as a 13th "month" when you page past Duodecember.
- **Navigation**: « Year / ‹ Month / Today / Month › / Year ». The view resets to
  today every time the popup opens.

Notes:

- The Republican year is approximated as beginning on 22 Sept rather than on the
  true astronomical equinox, and the 5-vs-6 epagomenal rule follows the
  Gregorian leap cycle (the original calendar never settled on one).
- Days are counted with calendar arithmetic rather than by subtracting local
  midnights, so DST changes can't shift the date. (The original Cinnamon applet
  was off by one day for roughly half the year in southern-hemisphere time
  zones, where DST begins after 22 Sept.)

## Differences from the macOS version

- **Time zone**: this version always follows the system clock. The macOS app
  lets you pin a specific IANA zone from the menu; QML/Plasma has no
  first-class timezone database binding, so that's left out here. If you
  want it, the cleanest way in is a small C++ QML plugin using `QTimeZone`,
  or shelling out to `TZ=<zone> date` from JS via a DataSource — happy to
  wire either up if you want it.
- **DST handling**: same idea as upstream — days are measured local-midnight
  to local-midnight, so the decimal second stretches or squeezes on
  changeover days instead of the clock ever reading past `10:00:00`.
- **Redraw cadence**: same as upstream — once per decimal second (0.864s) in
  the seconds/fraction formats, once per decimal minute (86.4s) in the
  hours & minutes format.
- **No "Open at Login"** item — Plasma widgets persist with your panel
  layout automatically, so there's nothing to toggle.

## Project layout

```
metric-time-kde/
├── metadata.json           # plasmoid identity/metadata (Plasma 6 KPackage format)
├── install.sh              # installs/upgrades via kpackagetool
└── contents/
    ├── code/
    │   └── republican.js    # decimal calendar logic (names, date conversion)
    ├── ui/
    │   ├── main.qml         # panel + popup UI, decimal time math
    │   ├── CalendarView.qml # navigable decimal calendar grid
    │   └── configGeneral.qml
    └── config/
        ├── main.xml         # kcfg setting definitions
        └── config.qml       # settings-page registration
```

## Troubleshooting

**Upgraded but the popup still looks like the old version** — Plasma keeps a
widget's QML loaded (and cached) in the running shell, so it can keep showing the
old interface after an upgrade even though the new metadata is picked up. Restart it:

```
./install.sh --restart
```

(which clears `~/.cache/plasmashell/qmlcache` and runs `plasmashell --replace`).

**Still not showing?** Check the files landed, then look for QML errors:

```
ls ~/.local/share/plasma/plasmoids/com.github.finnianhblr.metrictime/contents/{ui,code}
plasmashell --replace 2>&1 | grep -i -E "metrictime|qml|republican"   # click the widget, watch output
# or, with plasma-sdk installed:
plasmoidviewer -a ~/.local/share/plasma/plasmoids/com.github.finnianhblr.metrictime
```

## Manual install (no script)

```bash
kpackagetool6 --type Plasma/Applet -i /path/to/metric-time-kde
```

Or symlink it straight into your local plasmoids folder for live editing
while you tweak `main.qml` (reload with `plasmashell --replace &` after
each change, or use `plasmoidviewer` for faster iteration):

```bash
ln -s /path/to/metric-time-kde ~/.local/share/plasma/plasmoids/com.github.finnianhblr.metrictime
```
