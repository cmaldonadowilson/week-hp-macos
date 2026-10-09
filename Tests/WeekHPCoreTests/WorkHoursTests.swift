// SPDX-License-Identifier: GPL-2.0-or-later
//

import Foundation
import Testing
@testable import WeekHPCore

// Runs `body` with an empty defaults domain that is removed afterwards
private func withDefaults(_ body: (UserDefaults) -> Void) {
    let suite = "com.cmaldonadowilson.weekhp.tests.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suite)!
    defer { defaults.removePersistentDomain(forName: suite) }
    body(defaults)
}

@Test func standardHoursMatchTheGnomeExtension() {
    #expect(WorkHours.standard == WorkHours(dayStartHour: 9, dayEndHour: 18, fridayEndHour: 13))
    #expect(WorkHours.standard.isValid)
}

@Test(arguments: [
    WorkHours(dayStartHour: 18, dayEndHour: 9, fridayEndHour: 13),
    WorkHours(dayStartHour: 9, dayEndHour: 9, fridayEndHour: 13),
    WorkHours(dayStartHour: 9, dayEndHour: 18, fridayEndHour: 9),
    WorkHours(dayStartHour: -1, dayEndHour: 18, fridayEndHour: 13),
    WorkHours(dayStartHour: 9, dayEndHour: 25, fridayEndHour: 13),
    WorkHours(dayStartHour: .nan, dayEndHour: 18, fridayEndHour: 13),
])
func invalidHours(hours: WorkHours) {
    #expect(!hours.isValid)
}

@Test func loadWithoutSettingsGivesStandardHours() {
    withDefaults { defaults in
        #expect(WorkHours.load(from: defaults) == .standard)
    }
}

@Test func loadKeepsTheMissingKeysStandard() {
    withDefaults { defaults in
        defaults.set(8.5, forKey: WorkHours.dayStartHourKey)
        #expect(WorkHours.load(from: defaults) == WorkHours(dayStartHour: 8.5, dayEndHour: 18, fridayEndHour: 13))
    }
}

@Test func loadReadsAllKeys() {
    withDefaults { defaults in
        defaults.set(8, forKey: WorkHours.dayStartHourKey)
        defaults.set(17, forKey: WorkHours.dayEndHourKey)
        defaults.set(14, forKey: WorkHours.fridayEndHourKey)
        #expect(WorkHours.load(from: defaults) == WorkHours(dayStartHour: 8, dayEndHour: 17, fridayEndHour: 14))
    }
}

// `defaults write <id> dayEndHour 17` without -int/-float stores a string
@Test func loadParsesValuesWrittenAsStrings() {
    withDefaults { defaults in
        defaults.set("17", forKey: WorkHours.dayEndHourKey)
        #expect(WorkHours.load(from: defaults).dayEndHour == 17)
    }
}

@Test func loadFallsBackWhenTheCombinationIsInvalid() {
    withDefaults { defaults in
        defaults.set(20, forKey: WorkHours.dayStartHourKey)
        #expect(WorkHours.load(from: defaults) == .standard)
    }
}
