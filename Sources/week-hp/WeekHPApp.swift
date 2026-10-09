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
        switch LaunchCommand(arguments: Array(CommandLine.arguments.dropFirst())) {
        case .runApp:
            break
        case .printStatus:
            print(Translations().status(for: .current(schedule: Configuration.load().schedule)))
            return
        case .printVersion:
            print("week-hp \(WeekHP.version)")
            return
        case .printHelp:
            print(LaunchCommand.usage)
            return
        case .unknownOption(let option):
            FileHandle.standardError.write(Data("week-hp: unknown option '\(option)'\n\n\(LaunchCommand.usage)\n".utf8))
            exit(EX_USAGE)
        }

        guard isOnlyInstance() else {
            // Exits successfully, so `brew services` doesn't start it again
            print("Week HP is already running.")
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

    /// One Week HP per user, e.g. when `brew services` started it and it is
    /// also opened by hand. The lock is released when the process exits.
    private static func isOnlyInstance() -> Bool {
        let path = (NSTemporaryDirectory() as NSString).appendingPathComponent("\(WeekHP.bundleIdentifier).lock")
        // The descriptor stays open on purpose: closing it would release the lock
        let descriptor = open(path, O_CREAT | O_RDWR, 0o600)
        // If the lock file can't be created, run anyway
        return descriptor < 0 || flock(descriptor, LOCK_EX | LOCK_NB) == 0
    }
}
