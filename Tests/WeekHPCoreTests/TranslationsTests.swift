// SPDX-License-Identifier: GPL-2.0-or-later
//

import Foundation
import Testing
@testable import WeekHPCore

private func progress(day: Int, _ hour: Int, _ minute: Int = 0) -> WeekProgress {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    // 2026-10-05 is a Monday
    let date = calendar.date(from: DateComponents(year: 2026, month: 10, day: 5 + day, hour: hour, minute: minute))!
    return WeekProgress(at: date, calendar: calendar)
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
    #expect(texts == ["Lun 88%", "Mar 88%", "Mié 88%", "Jue 88%", "Vie 88%", "¡META!"])
}

@Test func unknownTextsAreLeftAsIs() {
    #expect(Translations(preferredLanguages: ["es"])("Week HP") == "Week HP")
}
