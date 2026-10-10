// SPDX-License-Identifier: GPL-2.0-or-later
//

import Foundation

public enum WeekHP {
    public static let name = "Week HP"
    public static let version = "1.3.0"
    public static let bundleIdentifier = "com.cmaldonadowilson.weekhp"
    public static let originalProjectURL = URL(string: "https://github.com/asterion/week-hp")!

    /// Settings written with `defaults write com.cmaldonadowilson.weekhp …`.
    /// The binary has no bundle, so the domain must be given explicitly.
    public static var userDefaults: UserDefaults {
        UserDefaults(suiteName: bundleIdentifier) ?? .standard
    }
}
