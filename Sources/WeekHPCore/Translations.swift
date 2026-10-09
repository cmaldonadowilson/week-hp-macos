// SPDX-License-Identifier: GPL-2.0-or-later
//
// The app has no bundle to hold .strings files, so the few texts it shows
// live here. English texts are the keys, like the gettext calls of the
// GNOME extension.

import Foundation

public struct Translations: Sendable {
    /// Language used, from the first of the user's preferred languages that is supported
    public let language: String

    private static let tables: [String: [String: String]] = [
        "es": [
            "Mon": "Lun",
            "Tue": "Mar",
            "Wed": "Mié",
            "Thu": "Jue",
            "Fri": "Vie",
            "GOAL!": "¡META!",
            "%@ %d%%": "%@ %d%%",
            "About Week HP": "Acerca de Week HP",
            "Quit Week HP": "Salir de Week HP",
            "Official macOS port of Week HP by asterion.": "Port oficial para macOS de Week HP, de asterion.",
        ],
        "fr": [
            "Mon": "Lun",
            "Tue": "Mar",
            "Wed": "Mer",
            "Thu": "Jeu",
            "Fri": "Ven",
            "GOAL!": "OBJECTIF !",
            "%@ %d%%": "%@ %d %%",
            "About Week HP": "À propos de Week HP",
            "Quit Week HP": "Quitter Week HP",
            "Official macOS port of Week HP by asterion.": "Portage officiel pour macOS de Week HP, par asterion.",
        ],
    ]

    public init(preferredLanguages: [String] = Locale.preferredLanguages) {
        // "es-CL" → "es", "zh-Hans-CN" → "zh"
        let codes = preferredLanguages.map {
            $0.split(whereSeparator: { $0 == "-" || $0 == "_" }).first.map { $0.lowercased() } ?? ""
        }
        language = codes.first { $0 == "en" || Self.tables[$0] != nil } ?? "en"
    }

    public func callAsFunction(_ text: String) -> String {
        Self.tables[language]?[text] ?? text
    }

    private static let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri"]

    /// Text shown next to the bar, e.g. "Wed 46%", or "GOAL!" once the week is complete.
    public func status(for progress: WeekProgress) -> String {
        guard !progress.isComplete, let today = progress.today else {
            return self("GOAL!")
        }
        return status(day: today, percent: progress.percent)
    }

    /// The widest texts `status(for:)` can return: every day with a two-digit
    /// percentage (it never reaches 100 before the goal) and the goal itself.
    public var longestStatusTexts: [String] {
        Self.dayNames.indices.map { status(day: $0, percent: 88) } + [self("GOAL!")]
    }

    private func status(day: Int, percent: Int) -> String {
        String(format: self("%@ %d%%"), self(Self.dayNames[day]), percent)
    }
}
