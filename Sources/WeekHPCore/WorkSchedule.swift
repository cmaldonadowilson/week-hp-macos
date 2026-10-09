// SPDX-License-Identifier: GPL-2.0-or-later
//

import Foundation

/// Work days and hours of the week. Hours are hours of the day (8.5 means 8:30).
///
/// Outside these hours a day counts as empty (before) or full (after).
/// With 0 and 24 each day progresses over the whole 24 hours.
public struct WorkSchedule: Equatable, Sendable {
    public static let standard = WorkSchedule(workDays: 5, dayStartHour: 9, dayEndHour: 18, lastDayEndHour: 13)
    public static let workDaysRange = 1...7

    // Keys for `defaults write com.cmaldonadowilson.weekhp <key> <value>`
    public static let workDaysKey = "workDays"
    public static let dayStartHourKey = "dayStartHour"
    public static let dayEndHourKey = "dayEndHour"
    public static let lastDayEndHourKey = "lastDayEndHour"
    /// Name of `lastDayEndHour` in version 1.0, when the week always ended on Friday
    public static let legacyFridayEndHourKey = "fridayEndHour"

    /// Work days from Monday: 5 means Monday to Friday
    public var workDays: Int
    public var dayStartHour: Double
    public var dayEndHour: Double
    // The last work day is a short day: the weekly goal is reached at this hour
    public var lastDayEndHour: Double

    public init(workDays: Int, dayStartHour: Double, dayEndHour: Double, lastDayEndHour: Double) {
        self.workDays = workDays
        self.dayStartHour = dayStartHour
        self.dayEndHour = dayEndHour
        self.lastDayEndHour = lastDayEndHour
    }

    /// Between 1 and 7 work days, every hour within 0...24, and both kinds
    /// of day end after they start.
    public var isValid: Bool {
        let hours = [dayStartHour, dayEndHour, lastDayEndHour]
        return Self.workDaysRange.contains(workDays)
            && hours.allSatisfy { $0.isFinite && (0...24).contains($0) }
            && dayEndHour > dayStartHour
            && lastDayEndHour > dayStartHour
    }

    /// Reads the schedule set by the user, falling back to `standard` for the
    /// missing values. An invalid combination falls back to `standard` entirely.
    public static func load(from defaults: UserDefaults) -> WorkSchedule {
        let lastDayKey = defaults.object(forKey: lastDayEndHourKey) == nil ? legacyFridayEndHourKey : lastDayEndHourKey
        let workDays = defaults.number(forKey: workDaysKey, fallback: Double(standard.workDays))

        let schedule = WorkSchedule(
            // A fractional or unreadable number of days is invalid
            workDays: workDays.rounded() == workDays ? Int(workDays) : 0,
            dayStartHour: defaults.number(forKey: dayStartHourKey, fallback: standard.dayStartHour),
            dayEndHour: defaults.number(forKey: dayEndHourKey, fallback: standard.dayEndHour),
            lastDayEndHour: defaults.number(forKey: lastDayKey, fallback: standard.lastDayEndHour)
        )
        return schedule.isValid ? schedule : standard
    }

    func save(to defaults: UserDefaults) {
        defaults.set(workDays, forKey: Self.workDaysKey)
        defaults.set(dayStartHour, forKey: Self.dayStartHourKey)
        defaults.set(dayEndHour, forKey: Self.dayEndHourKey)
        defaults.set(lastDayEndHour, forKey: Self.lastDayEndHourKey)
        defaults.removeObject(forKey: Self.legacyFridayEndHourKey)
    }
}

extension UserDefaults {
    /// The number stored for `key`, `fallback` when there is none, or NaN when
    /// it can't be read as a number (so the value is rejected as invalid).
    /// `defaults write` without -int or -float stores strings, which are parsed.
    func number(forKey key: String, fallback: Double) -> Double {
        switch object(forKey: key) {
        case nil:
            return fallback
        case let number as NSNumber:
            return number.doubleValue
        case let text as String:
            return Double(text.trimmingCharacters(in: .whitespaces)) ?? .nan
        default:
            return .nan
        }
    }
}
