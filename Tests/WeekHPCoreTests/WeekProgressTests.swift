// SPDX-License-Identifier: GPL-2.0-or-later
//

import Foundation
import Testing
@testable import WeekHPCore

// 2026-10-05 is a Monday
private let monday = 5

private func utcCalendar(firstWeekday: Int = 1) -> Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    calendar.firstWeekday = firstWeekday
    return calendar
}

private func progress(day: Int, _ hour: Int, _ minute: Int = 0,
                      schedule: WorkSchedule = .standard, calendar: Calendar = utcCalendar()) -> WeekProgress {
    let date = calendar.date(from: DateComponents(year: 2026, month: 10, day: day, hour: hour, minute: minute))!
    return WeekProgress(at: date, calendar: calendar, schedule: schedule)
}

private func isClose(_ a: Double, _ b: Double) -> Bool {
    abs(a - b) < 1e-9
}

@Test func mondayBeforeWorkIsEmpty() {
    let p = progress(day: monday, 8, 59)
    #expect(p.days == [0, 0, 0, 0, 0])
    #expect(p.today == 0)
    #expect(p.total == 0)
    #expect(p.percent == 0)
    #expect(BarAppearance.standard.level(for: p) == .low)
}

@Test func mondayMiddayIsHalfTheDay() {
    let p = progress(day: monday, 13, 30)
    #expect(isClose(p.days[0], 0.5))
    #expect(p.days[1...] == [0, 0, 0, 0])
    #expect(isClose(p.total, 0.1))
    #expect(p.percent == 10)
}

@Test func mondayAfterWorkIsFull() {
    let p = progress(day: monday, 18)
    #expect(p.days == [1, 0, 0, 0, 0])
    #expect(isClose(p.total, 0.2))
}

// Same moment as the "Wed 52%" screenshot of the GNOME extension
@Test func wednesdayMatchesTheScreenshot() {
    let p = progress(day: monday + 2, 14, 24)
    #expect(p.today == 2)
    #expect(p.days[0...1] == [1, 1])
    #expect(isClose(p.days[2], 0.6))
    #expect(p.percent == 52)
    #expect(BarAppearance.standard.level(for: p) == .mid)
}

@Test func fridayEndsAtOnePm() {
    let before = progress(day: monday + 4, 12, 59)
    #expect(before.today == 4)
    #expect(!before.isComplete)
    #expect(BarAppearance.standard.level(for: before) == .high)

    let after = progress(day: monday + 4, 13)
    #expect(after.days == [1, 1, 1, 1, 1])
    #expect(after.isComplete)
    #expect(BarAppearance.standard.level(for: after) == .complete)
}

@Test(arguments: [monday + 5, monday + 6])
func weekendIsComplete(day: Int) {
    for hour in [0, 12, 23] {
        let p = progress(day: day, hour)
        #expect(p.days == [1, 1, 1, 1, 1])
        #expect(p.today == nil)
        #expect(p.isComplete)
        #expect(p.percent == 100)
    }
}

@Test func nextMondayStartsOver() {
    let sunday = progress(day: monday + 6, 23, 59)
    #expect(sunday.isComplete)

    let nextMonday = progress(day: monday + 7, 0)
    #expect(nextMonday.total == 0)
    #expect(nextMonday.today == 0)
}

@Test func firstDayOfTheWeekSettingDoesNotMatter() {
    // Locales starting the week on Monday must give the same result
    for day in monday...(monday + 6) {
        #expect(progress(day: day, 15) == progress(day: day, 15, calendar: utcCalendar(firstWeekday: 2)))
    }
}

@Test func usesTheCalendarTimeZone() {
    // 12:00 UTC on Monday is still 09:00 in Santiago (UTC-3)
    let date = utcCalendar().date(from: DateComponents(year: 2026, month: 10, day: monday, hour: 12))!
    var santiago = utcCalendar()
    santiago.timeZone = TimeZone(identifier: "America/Santiago")!
    #expect(WeekProgress(at: date, calendar: santiago).total == 0)
}

@Test func customHoursOverTheWholeDay() {
    let allDay = WorkSchedule(workDays: 5, dayStartHour: 0, dayEndHour: 24, lastDayEndHour: 24)
    let p = progress(day: monday, 12, schedule: allDay)
    #expect(isClose(p.days[0], 0.5))

    let friday = progress(day: monday + 4, 23, 59, schedule: allDay)
    #expect(!friday.isComplete)
}

@Test(arguments: [
    (0.0, WeekProgress.Level.low),
    (0.39, .low),
    (0.4, .mid),
    (0.79, .mid),
    (0.8, .high),
    (0.99, .high),
    (1.0, .complete),
])
func levelThresholds(total: Double, expected: WeekProgress.Level) {
    #expect(WeekProgress.Level(total: total) == expected)
}

private func schedule(workDays: Int) -> WorkSchedule {
    var schedule = WorkSchedule.standard
    schedule.workDays = workDays
    return schedule
}

@Test func sixDayWeekEndsOnSaturday() {
    let sixDays = schedule(workDays: 6)
    // Friday is a normal day now, Saturday is the short last day
    let friday = progress(day: monday + 4, 18, schedule: sixDays)
    #expect(friday.days == [1, 1, 1, 1, 1, 0])
    #expect(!friday.isComplete)

    let saturday = progress(day: monday + 5, 11, schedule: sixDays)
    #expect(saturday.today == 5)
    #expect(isClose(saturday.days[5], 0.5))
    #expect(progress(day: monday + 5, 13, schedule: sixDays).isComplete)

    let sunday = progress(day: monday + 6, 10, schedule: sixDays)
    #expect(sunday.today == nil)
    #expect(sunday.days.count == 6)
}

@Test func fourDayWeekLeavesFridayFull() {
    let fourDays = schedule(workDays: 4)
    #expect(progress(day: monday + 3, 13, schedule: fourDays).isComplete)
    let friday = progress(day: monday + 4, 9, schedule: fourDays)
    #expect(friday.days == [1, 1, 1, 1])
    #expect(friday.today == nil)
}

@Test func sevenDayWeekHasNoWeekend() {
    let everyDay = schedule(workDays: 7)
    let saturday = progress(day: monday + 5, 18, schedule: everyDay)
    #expect(saturday.days == [1, 1, 1, 1, 1, 1, 0])
    #expect(saturday.today == 5)
    #expect(progress(day: monday + 6, 13, schedule: everyDay).isComplete)
}

@Test func oneDayWeekIsOnlyAShortMonday() {
    let oneDay = schedule(workDays: 1)
    // The only day is also the last one, so it ends at 13:00
    #expect(isClose(progress(day: monday, 11, schedule: oneDay).total, 0.5))
    #expect(progress(day: monday, 13, schedule: oneDay).isComplete)
    #expect(progress(day: monday + 1, 8, schedule: oneDay).isComplete)
}

// Like the Cinnamon applet: a day that ends when it starts is full from its start
@Test func dayWithoutLengthIsFullFromItsStart() {
    let noLength = WorkSchedule(workDays: 5, dayStartHour: 9, dayEndHour: 9, lastDayEndHour: 13)
    #expect(progress(day: monday, 8, 59, schedule: noLength).days[0] == 0)
    #expect(progress(day: monday, 9, schedule: noLength).days[0] == 1)
}

@Test(arguments: [
    (0.0, WeekProgress.Level.low),
    (0.24, .low),
    (0.25, .mid),
    (0.59, .mid),
    (0.6, .high),
    (0.99, .high),
    (1.0, .complete),
])
func customThresholds(total: Double, expected: WeekProgress.Level) {
    #expect(WeekProgress.Level(total: total, midThreshold: 25, highThreshold: 60) == expected)
}

// The color must match the percentage shown: at "40%" the bar is already yellow
@Test func thresholdsMatchTheShownPercentage() {
    // Tuesday at 18:00 is exactly 2 of 5 days
    let p = progress(day: monday + 1, 18)
    #expect(p.percent == 40)
    #expect(BarAppearance.standard.level(for: p) == .mid)
}
