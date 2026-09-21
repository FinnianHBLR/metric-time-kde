# Metric Time (KDE Plasma)

A Plasma panel widget that shows decimal (metric) time — the KDE counterpart to
[metric-time-mac](https://github.com/FinnianHBLR/metric-time-mac).

The day is split into **10 hours of 100 minutes of 100 seconds**, so midnight is
`0:00:00 M`, noon is `5:00:00 M`, and one decimal second is 0.864 seconds.
The trailing `M` marks the reading as metric.

The popup also has a French-Revolutionary-style **decimal calendar** (12 months of
30 days, 5–6 epagomenal days at year's end), ported from the
[Cinnamon applet](https://github.com/Arranlr/Decimal-Time-and-Calendar-Linux-Mint-Applet).

## Install
```bash
kpackagetool6 --type Plasma/Applet -i build/metric-time-[version].plasmoid

```
## Remove
```bash
kpackagetool6 --type Plasma/Applet -r com.github.finnianhblr.metrictime
```

## Create new build
```bash
sudo pacman -S zip
zip -r build/metric-time-[new_version].plasmoid metadata.json contents

```

## Settings

Right-click the widget on the panel → **Configure Metric Time…**

- **Show** — hours & minutes (`5:43`), hours/minutes/seconds (`5:43:21`), or
  the raw day fraction (`.54321`)
- **Suffix** — toggle the trailing `M` marker
- **Popup** — show or hide the decimal calendar (on by default). Today's
  decimal date stays visible either way.

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

## Troubleshooting

**Upgraded but the popup still looks like the old version** — Plasma keeps a
widget's QML loaded (and cached) in the running shell, so it can keep showing the
old interface after an upgrade even though the new metadata is picked up. Restart it:

```
./install.sh --restart
```