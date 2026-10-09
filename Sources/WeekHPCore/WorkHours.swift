// SPDX-License-Identifier: GPL-2.0-or-later
//

import Foundation

/// Working hours of the week, as hours of the day (8.5 means 8:30).
///
/// Outside these hours a day counts as empty (before) or full (after).
/// With 0 and 24 each day progresses over the whole 24 hours.
public struct WorkHours: Equatable, Sendable {
    public static let standard = WorkHours(dayStartHour: 9, dayEndHour: 18, fridayEndHour: 13)

    // Keys for `defaults write com.cmaldonadowilson.weekhp <key> <value>`
    public static let dayStartHourKey = "dayStartHour"
    public static let dayEndHourKey = "dayEndHour"
    public static let fridayEndHourKey = "fridayEndHour"

    public var dayStartHour: Double
    public var dayEndHour: Double
    // Friday is a short day: the weekly goal is reached at this hour
    public var fridayEndHour: Double

    public init(dayStartHour: Double, dayEndHour: Double, fridayEndHour: Double) {
        self.dayStartHour = dayStartHour
        self.dayEndHour = dayEndHour
        self.fridayEndHour = fridayEndHour
    }

    /// Every hour within 0...24 and both workdays end after they start.
    public var isValid: Bool {
        let hours = [dayStartHour, dayEndHour, fridayEndHour]
        return hours.allSatisfy { $0.isFinite && (0...24).contains($0) }
            && dayEndHour > dayStartHour
            && fridayEndHour > dayStartHour
    }

    /// Reads the hours set by the user, falling back to `standard` for the
    /// missing ones. An invalid combination falls back to `standard` entirely.
    public static func load(from defaults: UserDefaults) -> WorkHours {
        func value(_ key: String, _ fallback: Double) -> Double {
            // double(forKey:) also parses values written as strings
            defaults.object(forKey: key) == nil ? fallback : defaults.double(forKey: key)
        }

        let hours = WorkHours(
            dayStartHour: value(dayStartHourKey, standard.dayStartHour),
            dayEndHour: value(dayEndHourKey, standard.dayEndHour),
            fridayEndHour: value(fridayEndHourKey, standard.fridayEndHour)
        )
        return hours.isValid ? hours : standard
    }
}
