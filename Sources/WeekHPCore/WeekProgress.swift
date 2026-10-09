// SPDX-License-Identifier: GPL-2.0-or-later
//

import Foundation

/// Work week progress at a given time.
public struct WeekProgress: Equatable, Sendable {
    public static let workDays = 5

    /// Progress of each work day from Monday to Friday (0...1)
    public let days: [Double]
    /// Index of the current day (0 = Monday … 4 = Friday), nil on weekends
    public let today: Int?
    /// Total progress of the week (0...1)
    public let total: Double

    public var isComplete: Bool { total >= 1 }

    /// Whole percentage of the week, rounded down like the GNOME extension.
    /// The epsilon keeps values such as 0.52 from showing up as 51%.
    public var percent: Int { Int((total * 100 + 1e-9).rounded(.down)) }

    /// Color of the bar. Like in games: red when low, yellow at half,
    /// green when nearly full.
    public enum Level: Equatable, Sendable {
        case low, mid, high, complete

        public init(total: Double) {
            if total >= 1 {
                self = .complete
            } else if total >= 0.8 {
                self = .high
            } else if total >= 0.4 {
                self = .mid
            } else {
                self = .low
            }
        }
    }

    public var level: Level { Level(total: total) }

    /// - Parameters:
    ///   - date: the moment to measure
    ///   - calendar: provides the local weekday, hour and minute of `date`
    ///   - hours: working hours, `WorkHours.standard` unless set by the user
    public init(at date: Date, calendar: Calendar = .current, hours: WorkHours = .standard) {
        let components = calendar.dateComponents([.weekday, .hour, .minute], from: date)
        // Calendar weekdays go from 1 = Sunday to 7 = Saturday; shift them to 0 = Monday … 6 = Sunday
        let weekday = ((components.weekday ?? 1) + 5) % 7

        if weekday >= Self.workDays {
            days = Array(repeating: 1, count: Self.workDays)
            today = nil
            total = 1
            return
        }

        let hour = Double(components.hour ?? 0) + Double(components.minute ?? 0) / 60
        let endHour = weekday == Self.workDays - 1 ? hours.fridayEndHour : hours.dayEndHour
        let todayFraction = min(max((hour - hours.dayStartHour) / (endHour - hours.dayStartHour), 0), 1)

        days = (0..<Self.workDays).map { i in
            if i < weekday {
                return 1
            }
            return i == weekday ? todayFraction : 0
        }
        today = weekday
        total = days.reduce(0, +) / Double(Self.workDays)
    }

    /// Progress right now in the local time zone, with the working hours set by the user.
    public static func current(defaults: UserDefaults = WeekHP.userDefaults) -> WeekProgress {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        return WeekProgress(at: Date(), calendar: calendar, hours: WorkHours.load(from: defaults))
    }
}
