// SPDX-License-Identifier: GPL-2.0-or-later
//

import Foundation

/// Everything the user can change, stored in the `com.cmaldonadowilson.weekhp`
/// defaults domain: from the Settings window or with `defaults write`.
public struct Configuration: Equatable, Sendable {
    public static let standard = Configuration(schedule: .standard, appearance: .standard)

    public static let keys = [
        WorkSchedule.workDaysKey,
        WorkSchedule.dayStartHourKey,
        WorkSchedule.dayEndHourKey,
        WorkSchedule.lastDayEndHourKey,
        WorkSchedule.legacyFridayEndHourKey,
        BarAppearance.segmentWidthKey,
        BarAppearance.midThresholdKey,
        BarAppearance.highThresholdKey,
        BarAppearance.fillLowColorKey,
        BarAppearance.fillMidColorKey,
        BarAppearance.fillHighColorKey,
        BarAppearance.goalColorKey,
        BarAppearance.compactKey,
    ]

    public var schedule: WorkSchedule
    public var appearance: BarAppearance

    public init(schedule: WorkSchedule, appearance: BarAppearance) {
        self.schedule = schedule
        self.appearance = appearance
    }

    public static func load(from defaults: UserDefaults = WeekHP.userDefaults) -> Configuration {
        Configuration(schedule: .load(from: defaults), appearance: .load(from: defaults))
    }

    /// Writes every value; colors left at their default are removed.
    public func save(to defaults: UserDefaults = WeekHP.userDefaults) {
        schedule.save(to: defaults)
        appearance.save(to: defaults)
    }

    /// Goes back to the default values by removing every setting.
    public static func reset(in defaults: UserDefaults = WeekHP.userDefaults) {
        for key in keys {
            defaults.removeObject(forKey: key)
        }
    }
}
