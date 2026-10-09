// SPDX-License-Identifier: GPL-2.0-or-later
//

import Foundation

/// Work week progress at a given time.
public struct WeekProgress: Equatable, Sendable {
    /// Progress of each work day from Monday (0...1)
    public let days: [Double]
    /// Index of the current day (0 = Monday … 6 = Sunday), nil outside the work week
    public let today: Int?
    /// Total progress of the week (0...1)
    public let total: Double

    public var isComplete: Bool { total >= 1 }

    /// Whole percentage of the week, rounded down like the GNOME extension.
    /// The epsilon keeps values such as 0.52 from showing up as 51%.
    public var percent: Int { Int((total * 100 + Self.epsilon).rounded(.down)) }

    private static let epsilon = 1e-9

    /// Color of the bar. Like in games: red when low, yellow at half,
    /// green when nearly full.
    public enum Level: Equatable, Sendable {
        case low, mid, high, complete

        /// - Parameters:
        ///   - total: total progress of the week (0...1)
        ///   - midThreshold: percentage where the bar turns yellow
        ///   - highThreshold: percentage where the bar turns green
        public init(total: Double, midThreshold: Double = 40, highThreshold: Double = 80) {
            // Compared like the percentage shown, so 40% is never still red
            let percent = total * 100 + WeekProgress.epsilon
            if total >= 1 {
                self = .complete
            } else if percent >= highThreshold {
                self = .high
            } else if percent >= midThreshold {
                self = .mid
            } else {
                self = .low
            }
        }
    }

    /// - Parameters:
    ///   - date: the moment to measure
    ///   - calendar: provides the local weekday, hour and minute of `date`
    ///   - schedule: work days and hours, `WorkSchedule.standard` unless set by the user
    public init(at date: Date, calendar: Calendar = .current, schedule: WorkSchedule = .standard) {
        let workDays = schedule.workDays
        let components = calendar.dateComponents([.weekday, .hour, .minute], from: date)
        // Calendar weekdays go from 1 = Sunday to 7 = Saturday; shift them to 0 = Monday … 6 = Sunday
        let weekday = ((components.weekday ?? 1) + 5) % 7

        if weekday >= workDays {
            days = Array(repeating: 1, count: workDays)
            today = nil
            total = 1
            return
        }

        let hour = Double(components.hour ?? 0) + Double(components.minute ?? 0) / 60
        let endHour = weekday == workDays - 1 ? schedule.lastDayEndHour : schedule.dayEndHour
        let span = endHour - schedule.dayStartHour
        // A day that ends when it starts is full from its start, like in the Cinnamon applet
        let todayFraction = span > 0
            ? min(max((hour - schedule.dayStartHour) / span, 0), 1)
            : (hour >= schedule.dayStartHour ? 1 : 0)

        days = (0..<workDays).map { i in
            if i < weekday {
                return 1
            }
            return i == weekday ? todayFraction : 0
        }
        today = weekday
        total = days.reduce(0, +) / Double(workDays)
    }

    /// Progress right now in the local time zone.
    public static func current(schedule: WorkSchedule) -> WeekProgress {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        return WeekProgress(at: Date(), calendar: calendar, schedule: schedule)
    }
}
