# Week HP for macOS

A retro 2D platformer health bar for the macOS menu bar that fills up
as your work week goes by. Reach Friday and… **GOAL!** ⭐

This is the official macOS port of [Week HP](https://github.com/asterion/week-hp),
the GNOME Shell extension by [asterion](https://github.com/asterion),
made with the author's permission.

> **Status:** work in progress. The first release (1.0.0) is not out yet.

## How it works

The bar has five segments, one for each day from Monday to Friday.
The current day fills up little by little during working hours, and the color
changes as you make progress, just like a health bar in a video game.

- Days progress from **9:00 to 18:00**. Friday is a short day and ends at **13:00**.
- **Red** below 40%, **yellow** below 80%, **green** after that.
- When Friday's workday ends, the heart turns into a star and the weekly goal is complete.
  The bar stays full over the weekend and starts again on Monday.

Week HP follows your system language and speaks **English, Spanish and French**.

## Requirements

macOS 13 (Ventura) or later.

## Installation

Coming soon through a Homebrew tap.

## Building from source

```bash
make build
.build/release/week-hp --version
```

Run the tests with `make test`. They use Swift Testing, which needs
Swift 6 (Command Line Tools 16 or later); building the app does not.

## Credits

Original idea, design and GNOME Shell extension:
[asterion/week-hp](https://github.com/asterion/week-hp).

## License

[GPL-2.0-or-later](LICENSE), same as the original project.
