// SPDX-License-Identifier: GPL-2.0-or-later
//
// Week HP for macOS: a retro 2D platformer health bar in the menu bar.
// It fills up from Monday to Friday; when Friday ends, the weekly goals are complete.

import AppKit
import WeekHPCore

@main
enum WeekHPApp {
    @MainActor
    static func main() {
        if CommandLine.arguments.contains("--version") {
            print("week-hp \(WeekHP.version)")
            return
        }

        let app = NSApplication.shared
        let controller = StatusController()
        app.delegate = controller
        // Menu bar only: no Dock icon and no app menu
        app.setActivationPolicy(.accessory)
        // The delegate is weak: keep the controller alive while the app runs
        withExtendedLifetime(controller) {
            app.run()
        }
    }
}
