// SPDX-License-Identifier: GPL-2.0-or-later
//

import Foundation
import Testing
@testable import WeekHPCore

// Runs `body` with an empty defaults domain that is removed afterwards
func withDefaults(_ body: (UserDefaults) -> Void) {
    let suite = "com.cmaldonadowilson.weekhp.tests.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suite)!
    defer { defaults.removePersistentDomain(forName: suite) }
    body(defaults)
}

@Test func standardScheduleMatchesTheGnomeExtension() {
    #expect(WorkSchedule.standard == WorkSchedule(workDays: 5, dayStartHour: 9, dayEndHour: 18, lastDayEndHour: 13))
    #expect(WorkSchedule.standard.isValid)
}

@Test(arguments: [
    WorkSchedule(workDays: 5, dayStartHour: 18, dayEndHour: 9, lastDayEndHour: 13),
    WorkSchedule(workDays: 5, dayStartHour: 9, dayEndHour: 9, lastDayEndHour: 13),
    WorkSchedule(workDays: 5, dayStartHour: 9, dayEndHour: 18, lastDayEndHour: 9),
    WorkSchedule(workDays: 5, dayStartHour: -1, dayEndHour: 18, lastDayEndHour: 13),
    WorkSchedule(workDays: 5, dayStartHour: 9, dayEndHour: 25, lastDayEndHour: 13),
    WorkSchedule(workDays: 5, dayStartHour: .nan, dayEndHour: 18, lastDayEndHour: 13),
    WorkSchedule(workDays: 0, dayStartHour: 9, dayEndHour: 18, lastDayEndHour: 13),
    WorkSchedule(workDays: 8, dayStartHour: 9, dayEndHour: 18, lastDayEndHour: 13),
])
func invalidSchedules(schedule: WorkSchedule) {
    #expect(!schedule.isValid)
}

@Test func loadWithoutSettingsGivesTheStandardSchedule() {
    withDefaults { defaults in
        #expect(WorkSchedule.load(from: defaults) == .standard)
    }
}

@Test func loadKeepsTheMissingKeysStandard() {
    withDefaults { defaults in
        defaults.set(8.5, forKey: WorkSchedule.dayStartHourKey)
        #expect(WorkSchedule.load(from: defaults)
            == WorkSchedule(workDays: 5, dayStartHour: 8.5, dayEndHour: 18, lastDayEndHour: 13))
    }
}

@Test func loadReadsAllScheduleKeys() {
    withDefaults { defaults in
        defaults.set(6, forKey: WorkSchedule.workDaysKey)
        defaults.set(8, forKey: WorkSchedule.dayStartHourKey)
        defaults.set(17, forKey: WorkSchedule.dayEndHourKey)
        defaults.set(14, forKey: WorkSchedule.lastDayEndHourKey)
        #expect(WorkSchedule.load(from: defaults)
            == WorkSchedule(workDays: 6, dayStartHour: 8, dayEndHour: 17, lastDayEndHour: 14))
    }
}

// `defaults write <id> dayEndHour 17` without -int/-float stores a string
@Test func loadParsesValuesWrittenAsStrings() {
    withDefaults { defaults in
        defaults.set("17", forKey: WorkSchedule.dayEndHourKey)
        defaults.set("6", forKey: WorkSchedule.workDaysKey)
        let schedule = WorkSchedule.load(from: defaults)
        #expect(schedule.dayEndHour == 17)
        #expect(schedule.workDays == 6)
    }
}

@Test(arguments: ["abc", "5.5", "9"])
func loadRejectsUnreadableWorkDays(value: String) {
    withDefaults { defaults in
        defaults.set(value, forKey: WorkSchedule.workDaysKey)
        #expect(WorkSchedule.load(from: defaults) == .standard)
    }
}

// Before, an unreadable hour was read as 0 (midnight) instead of being rejected
@Test func loadRejectsUnreadableHours() {
    withDefaults { defaults in
        defaults.set("nine", forKey: WorkSchedule.dayStartHourKey)
        #expect(WorkSchedule.load(from: defaults) == .standard)
    }
}

@Test func loadFallsBackWhenTheCombinationIsInvalid() {
    withDefaults { defaults in
        defaults.set(20, forKey: WorkSchedule.dayStartHourKey)
        #expect(WorkSchedule.load(from: defaults) == .standard)
    }
}

// Version 1.0 called the last day end hour `fridayEndHour`
@Test func loadReadsTheKeyOfVersion1() {
    withDefaults { defaults in
        defaults.set(15, forKey: WorkSchedule.legacyFridayEndHourKey)
        #expect(WorkSchedule.load(from: defaults).lastDayEndHour == 15)

        defaults.set(14, forKey: WorkSchedule.lastDayEndHourKey)
        #expect(WorkSchedule.load(from: defaults).lastDayEndHour == 14)
    }
}

@Test func saveReplacesTheKeyOfVersion1() {
    withDefaults { defaults in
        defaults.set(15, forKey: WorkSchedule.legacyFridayEndHourKey)
        var schedule = WorkSchedule.load(from: defaults)
        schedule.workDays = 6
        schedule.save(to: defaults)

        #expect(defaults.object(forKey: WorkSchedule.legacyFridayEndHourKey) == nil)
        #expect(WorkSchedule.load(from: defaults)
            == WorkSchedule(workDays: 6, dayStartHour: 9, dayEndHour: 18, lastDayEndHour: 15))
    }
}
