# Metric Time (KDE Plasma)

A Plasma panel widget that shows decimal (metric) time — the KDE counterpart to
[metric-time-mac](https://github.com/FinnianHBLR/metric-time-mac).

The day is split into **10 hours of 100 minutes of 100 seconds**, so midnight is
`0:00:00 M`, noon is `5:00:00 M`, and one decimal second is 0.864 SI seconds.
The trailing `M` marks the reading as metric.

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
kpackagetool6 --type Plasma/Applet -r org.kde.plasma.metrictime
```

(use `kpackagetool5` instead if your system is still on Plasma 5).

## Settings

Right-click the widget on the panel → **Configure Metric Time…**

- **Show** — hours & minutes (`5:43`), hours/minutes/seconds (`5:43:21`), or
  the raw day fraction (`.54321`)
- **Suffix** — toggle the trailing `M` marker
- **In panel** — optionally show the conventional time next to the decimal
  one right on the panel (it's always shown in the popup regardless)

Click the widget to open a popup with both the decimal and conventional time
and the raw day fraction.

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
    ├── ui/
    │   ├── main.qml         # panel + popup UI, decimal time math
    │   └── configGeneral.qml
    └── config/
        ├── main.xml         # kcfg setting definitions
        └── config.qml       # settings-page registration
```

## Manual install (no script)

```bash
kpackagetool6 --type Plasma/Applet -i /path/to/metric-time-kde
```

Or symlink it straight into your local plasmoids folder for live editing
while you tweak `main.qml` (reload with `plasmashell --replace &` after
each change, or use `plasmoidviewer` for faster iteration):

```bash
ln -s /path/to/metric-time-kde ~/.local/share/plasma/plasmoids/org.kde.plasma.metrictime
```
