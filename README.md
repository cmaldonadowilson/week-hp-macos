# Week HP for macOS

A retro 2D platformer health bar for the macOS menu bar that fills up
as your work week goes by. Reach Friday and… **GOAL!** ⭐

This is the official macOS port of [Week HP](https://github.com/asterion/week-hp),
the GNOME Shell extension by [asterion](https://github.com/asterion),
made with the author's permission.

## How it works

The bar has one segment for each work day, from Monday to Friday by default.
The current day fills up little by little during working hours, and the color
changes as you make progress, just like a health bar in a video game.

- Days progress from **9:00 to 18:00**. Friday, the last work day, is a short
  day and ends at **13:00**.
- **Red** below 40%, **yellow** below 80%, **green** after that.
- When the last workday ends, the heart turns into a star and the weekly goal is complete.
  The bar stays full over the weekend and starts again on Monday.
- Hover over it to see the day and the percentage in a tooltip.
- Open its menu to see how much is left: of today (`3 h 36 min left today`)
  and until the goal (`Goal in 2 days (Fri 13:00)`).

Week HP follows your system language and speaks **English, Spanish and French**.
It lives only in the menu bar: quit it from its menu.

## Settings

Choose **Settings…** in the Week HP menu to change, with the changes showing up
right away:

- **Work schedule**: work days per week (1 to 7, from Monday), when a day
  starts, when it counts as complete, and when the last work day ends.
- **Bar appearance**: compact mode, segment width and the progress where the
  bar turns yellow and green.
- **Colors**: the fill color for each progress level and the goal color. By
  default the goal color gets darker on a light menu bar; a color you choose
  is used as is.

**Restore default values** at the bottom goes back to the original settings.

If the menu bar is short of room, for example on a MacBook with a notch,
choose **Compact Mode** in the Week HP menu: it hides the text and keeps the
icon and the bar, about 40% narrower. The day and the percentage are still
in the tooltip.
These settings come from the
[Week HP applet for Cinnamon](https://github.com/asterion/week-hp-cinnamon).

They can also be set from the terminal, in the `com.cmaldonadowilson.weekhp`
domain. Changes show up within a minute:

```bash
defaults write com.cmaldonadowilson.weekhp workDays 6
defaults write com.cmaldonadowilson.weekhp dayStartHour 8.5   # 8:30
defaults write com.cmaldonadowilson.weekhp goalColor '#00F5D4'
```

| Key | Default | Values |
|---|---|---|
| `workDays` | 5 | 1 to 7 |
| `dayStartHour` | 9 | 0 to 24, with decimals |
| `dayEndHour` | 18 | 0 to 24, later than `dayStartHour` |
| `lastDayEndHour` | 13 | 0 to 24, later than `dayStartHour` |
| `compactMode` | false | `true` hides the text |
| `segmentWidth` | 14 | 4 to 40 points |
| `midThreshold` | 40 | 0 to 100 %, below `highThreshold` |
| `highThreshold` | 80 | 0 to 100 % |
| `fillLowColor`, `fillMidColor`, `fillHighColor`, `goalColor` | | `#RRGGBB` |

Values that don't make sense fall back to their defaults. `fridayEndHour`, the
name of `lastDayEndHour` in version 1.0, still works. To go back to the defaults:

```bash
defaults delete com.cmaldonadowilson.weekhp
```

## Command line

```bash
week-hp --print     # the week progress without opening the app, e.g. "Wed 52%"
week-hp --version
week-hp --help
```

To try another language, add `-AppleLanguages '(fr)'` (or `es`, `en`).
Only one Week HP runs at a time: opening it again while it's running does nothing.

## Requirements

macOS 13 (Ventura) or later.

## Installation

With [Homebrew](https://brew.sh):

```bash
brew install cmaldonadowilson/tap/week-hp
brew services start week-hp   # open it now and at every login
```

Use the full name `cmaldonadowilson/tap/week-hp` the first time: Homebrew
trusts formulae from other taps only when they are named in full.
On macOS 15 or later it installs a prebuilt bottle; on macOS 13 and 14 it is
built from source, which needs the Command Line Tools (`xcode-select --install`).
If your menu bar is full, macOS may hide Week HP behind the notch. Compact
Mode makes it narrower; if you can't reach its menu, turn it on with
`defaults write com.cmaldonadowilson.weekhp compactMode -bool true`.

To remove it:

```bash
brew services stop week-hp
brew uninstall week-hp
```

## Building from source

```bash
make build
.build/release/week-hp
```

`week-hp --version` prints the version without opening the app.

Run the tests with `make test`. They use Swift Testing, which needs
Swift 6 (Command Line Tools 16 or later); building the app does not.

## Releasing

1. Update `WeekHP.version` in `Sources/WeekHPCore/WeekHP.swift`.
2. Tag the commit (`git tag -a v1.3.0`), push the tag and publish a GitHub
   release for it.

The `Update Homebrew` workflow then asks the
[tap](https://github.com/cmaldonadowilson/homebrew-tap) to update the formula,
which builds and publishes the bottles on its own, usually within half an hour.

## Credits

Original idea, design and GNOME Shell extension:
[asterion/week-hp](https://github.com/asterion/week-hp). Settings and their
translations: [asterion/week-hp-cinnamon](https://github.com/asterion/week-hp-cinnamon).

## License

[GPL-2.0-or-later](LICENSE), same as the original project.
