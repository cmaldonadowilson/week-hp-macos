// SPDX-License-Identifier: GPL-2.0-or-later
//
// Week HP for macOS: a retro 2D platformer health bar in the menu bar.
// It fills up from Monday to Friday; when Friday ends, the weekly goals are complete.

import WeekHPCore

if CommandLine.arguments.contains("--version") {
    print("week-hp \(WeekHP.version)")
}
