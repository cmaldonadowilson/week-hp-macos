// SPDX-License-Identifier: GPL-2.0-or-later
//

import Foundation

/// What is left of the work week at a given time: of the current day, and
/// until the weekly goal. Shown at the top of the menu.
public struct WeekOutlook: Equatable, Sendable {
    public enum Today: Equatable, Sendable {
        /// A work day that has not started yet, at this hour
        case startsAt(Double)
        /// Minutes left of the current work day
        case minutesLeft(Int)
        /// A work day already full
        case complete
        /// Not a work day
        case dayOff
    }

    public enum Goal: Equatable, Sendable {
        /// Reached today, tomorrow or in some days, at the end hour of the last work day
        case today(at: Double)
        case tomorrow(at: Double)
        case inDays(Int, weekday: Int, at: Double)
        /// Already reached: the next week starts on Monday at this hour
        case reached(nextWeekStartsAt: Double)
    }

    public let today: Today
    public let goal: Goal

    /// - Parameters:
    ///   - date: the moment to describe
    ///   - calendar: provides the local weekday, hour and minute of `date`
    ///   - schedule: work days and hours
    public init(at date: Date, calendar: Calendar = .current, schedule: WorkSchedule = .standard) {
        let components = calendar.dateComponents([.weekday, .hour, .minute], from: date)
        // Calendar weekdays go from 1 = Sunday to 7 = Saturday; shift them to 0 = Monday … 6 = Sunday
        let weekday = ((components.weekday ?? 1) + 5) % 7
        let minutes = (components.hour ?? 0) * 60 + (components.minute ?? 0)
        let lastDay = schedule.workDays - 1

        if weekday > lastDay {
            today = .dayOff
        } else {
            let endHour = weekday == lastDay ? schedule.lastDayEndHour : schedule.dayEndHour
            if Double(minutes) < schedule.dayStartHour * 60 {
                today = .startsAt(schedule.dayStartHour)
            } else if Double(minutes) < endHour * 60 {
                today = .minutesLeft(Int((endHour * 60 - Double(minutes)).rounded(.up)))
            } else {
                today = .complete
            }
        }

        // The goal is reached exactly when the bar is full
        if WeekProgress(at: date, calendar: calendar, schedule: schedule).isComplete {
            goal = .reached(nextWeekStartsAt: schedule.dayStartHour)
        } else {
            switch lastDay - weekday {
            case 0:
                goal = .today(at: schedule.lastDayEndHour)
            case 1:
                goal = .tomorrow(at: schedule.lastDayEndHour)
            case let days:
                goal = .inDays(days, weekday: lastDay, at: schedule.lastDayEndHour)
            }
        }
    }

    /// The outlook right now in the local time zone.
    public static func current(schedule: WorkSchedule) -> WeekOutlook {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        return WeekOutlook(at: Date(), calendar: calendar, schedule: schedule)
    }
}
