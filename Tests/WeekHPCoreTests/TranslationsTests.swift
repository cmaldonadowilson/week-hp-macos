// SPDX-License-Identifier: GPL-2.0-or-later
//

import Foundation
import Testing
@testable import WeekHPCore

private func progress(day: Int, _ hour: Int, _ minute: Int = 0, schedule: WorkSchedule = .standard) -> WeekProgress {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    // 2026-10-05 is a Monday
    let date = calendar.date(from: DateComponents(year: 2026, month: 10, day: 5 + day, hour: hour, minute: minute))!
    return WeekProgress(at: date, calendar: calendar, schedule: schedule)
}

@Test(arguments: [
    (["es-CL", "en-US"], "es"),
    (["fr-CA"], "fr"),
    (["en-GB", "es-ES"], "en"),
    (["de-DE", "fr-FR"], "fr"),
    (["zh-Hans-CN", "es_419"], "es"),
    (["de-DE"], "en"),
    ([], "en"),
])
func picksTheFirstSupportedLanguage(preferred: [String], expected: String) {
    #expect(Translations(preferredLanguages: preferred).language == expected)
}

// The "Mié 52%" screenshot of the GNOME extension, in every language
@Test(arguments: [
    ("en", "Wed 52%"),
    ("es", "Mié 52%"),
    ("fr", "Mer 52 %"),
])
func statusShowsTheDayAndPercentage(language: String, expected: String) {
    let wednesday = progress(day: 2, 14, 24)
    #expect(Translations(preferredLanguages: [language]).status(for: wednesday) == expected)
}

@Test(arguments: [
    ("en", "GOAL!"),
    ("es", "¡META!"),
    ("fr", "OBJECTIF !"),
])
func statusCelebratesTheCompleteWeek(language: String, expected: String) {
    let tr = Translations(preferredLanguages: [language])
    #expect(tr.status(for: progress(day: 4, 13)) == expected)
    #expect(tr.status(for: progress(day: 5, 10)) == expected)
}

@Test func longestTextsCoverEveryDayAndTheGoal() {
    let texts = Translations(preferredLanguages: ["es"]).longestStatusTexts
    #expect(texts == ["Lun 88%", "Mar 88%", "Mié 88%", "Jue 88%", "Vie 88%", "Sáb 88%", "Dom 88%", "¡META!"])
}

@Test(arguments: [("en", "Sat 91%"), ("es", "Sáb 91%"), ("fr", "Sam 91 %")])
func statusNamesTheWeekendWhenItIsWorked(language: String, expected: String) {
    var sixDays = WorkSchedule.standard
    sixDays.workDays = 6
    // Saturday 11:00 of a six-day week: 5 days and half of the short Saturday, 5.5 / 6
    let saturday = progress(day: 5, 11, schedule: sixDays)
    #expect(Translations(preferredLanguages: [language]).status(for: saturday) == expected)
}

@Test(arguments: [(1, "1 (Lun)"), (5, "5 (Lun–Vie)"), (7, "7 (Lun–Dom)")])
func workDaysNameTheirRange(count: Int, expected: String) {
    #expect(Translations(preferredLanguages: ["es"]).workDays(count) == expected)
}

@Test func percentagesFollowTheLanguage() {
    #expect(Translations(preferredLanguages: ["es"]).percentage(40) == "40%")
    #expect(Translations(preferredLanguages: ["fr"]).percentage(40) == "40 %")
}

@Test(arguments: [(0.0, "00:00"), (8.5, "08:30"), (9.25, "09:15"), (13.0, "13:00"), (24.0, "24:00")])
func hoursShowAsClockTimes(hours: Double, expected: String) {
    #expect(Translations.clockTime(hours) == expected)
}

// Every text of the Settings window is translated in both languages
@Test(arguments: ["es", "fr"])
func settingsTextsAreTranslated(language: String) {
    let tr = Translations(preferredLanguages: [language])
    let texts = [
        "Settings…", "Week HP Settings", "Work schedule", "Work days per week", "Day starts at",
        "Day is complete at", "Last work day ends at", "Bar appearance", "Segment width",
        "Turns yellow at", "Turns green at", "Colors", "Fill color: low progress",
        "Fill color: mid progress", "Fill color: high progress", "Goal color", "Restore default values",
    ]
    #expect(texts.filter { tr($0) == $0 } == [])
}

@Test func unknownTextsAreLeftAsIs() {
    #expect(Translations(preferredLanguages: ["es"])("Week HP") == "Week HP")
}
