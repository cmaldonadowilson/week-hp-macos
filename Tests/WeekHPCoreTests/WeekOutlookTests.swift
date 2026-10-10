// SPDX-License-Identifier: GPL-2.0-or-later
//

import Foundation
import Testing
@testable import WeekHPCore

// 2026-10-05 is a Monday
private func outlook(day: Int, _ hour: Int, _ minute: Int = 0, schedule: WorkSchedule = .standard) -> WeekOutlook {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    let date = calendar.date(from: DateComponents(year: 2026, month: 10, day: 5 + day, hour: hour, minute: minute))!
    return WeekOutlook(at: date, calendar: calendar, schedule: schedule)
}

@Test func workDayBeforeItStarts() {
    let o = outlook(day: 0, 8, 30)
    #expect(o.today == .startsAt(9))
    #expect(o.goal == .inDays(4, weekday: 4, at: 13))
}

// The moment of the "Wed 52%" screenshot
@Test func workDayInProgress() {
    let o = outlook(day: 2, 14, 24)
    #expect(o.today == .minutesLeft(216))
    #expect(o.goal == .inDays(2, weekday: 4, at: 13))
}

@Test func lastMinuteOfTheDay() {
    #expect(outlook(day: 2, 17, 59).today == .minutesLeft(1))
    #expect(outlook(day: 2, 18).today == .complete)
}

@Test func goalTomorrowAndToday() {
    #expect(outlook(day: 3, 10).goal == .tomorrow(at: 13))
    let friday = outlook(day: 4, 12)
    #expect(friday.today == .minutesLeft(60))
    #expect(friday.goal == .today(at: 13))
}

@Test func goalReachedOnFridayAfternoonAndTheWeekend() {
    let friday = outlook(day: 4, 13)
    #expect(friday.today == .complete)
    #expect(friday.goal == .reached(nextWeekStartsAt: 9))
    for day in [5, 6] {
        let weekend = outlook(day: day, 11)
        #expect(weekend.today == .dayOff)
        #expect(weekend.goal == .reached(nextWeekStartsAt: 9))
    }
}

@Test func followsTheSchedule() {
    let sixDays = WorkSchedule(workDays: 6, dayStartHour: 8.5, dayEndHour: 17.5, lastDayEndHour: 12)
    // Friday is a normal day of a six-day week; the goal is on Saturday at 12:00
    let friday = outlook(day: 4, 8, schedule: sixDays)
    #expect(friday.today == .startsAt(8.5))
    #expect(friday.goal == .tomorrow(at: 12))
    #expect(outlook(day: 4, 17, schedule: sixDays).today == .minutesLeft(30))
    #expect(outlook(day: 5, 12, schedule: sixDays).goal == .reached(nextWeekStartsAt: 8.5))
    #expect(outlook(day: 6, 9, schedule: sixDays).today == .dayOff)
}

@Test func linesOfTheMenu() {
    let es = Translations(preferredLanguages: ["es"])
    #expect(es.lines(for: outlook(day: 2, 14, 24)) == ["Quedan 3 h 36 min hoy", "Meta en 2 días (Vie 13:00)"])
    #expect(es.lines(for: outlook(day: 0, 8)) == ["El día empieza a las 09:00", "Meta en 4 días (Vie 13:00)"])
    #expect(es.lines(for: outlook(day: 3, 18)) == ["Hoy ya está completo", "Meta mañana a las 13:00"])
    #expect(es.lines(for: outlook(day: 4, 12, 15)) == ["Quedan 45 min hoy", "Meta hoy a las 13:00"])
    #expect(es.lines(for: outlook(day: 5, 10)) == ["Próxima semana: Lun 09:00"])

    let en = Translations(preferredLanguages: ["en"])
    #expect(en.lines(for: outlook(day: 2, 14, 24)) == ["3 h 36 min left today", "Goal in 2 days (Fri 13:00)"])
    #expect(en.lines(for: outlook(day: 4, 14)) == ["Today is complete", "Next week: Mon 09:00"])

    let fr = Translations(preferredLanguages: ["fr"])
    #expect(fr.lines(for: outlook(day: 2, 14, 24)) == ["Il reste 3 h 36 min aujourd’hui", "Objectif dans 2 jours (Ven 13:00)"])
}

@Test(arguments: [(45, "45 min"), (60, "1 h"), (216, "3 h 36 min"), (480, "8 h"), (1, "1 min")])
func durationsShowHoursAndMinutes(minutes: Int, expected: String) {
    #expect(Translations.duration(minutes: minutes) == expected)
}
