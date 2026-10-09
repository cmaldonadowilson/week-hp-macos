// SPDX-License-Identifier: GPL-2.0-or-later
//

import Foundation
import Testing
@testable import WeekHPCore

@Test func savedConfigurationLoadsBack() {
    withDefaults { defaults in
        var configuration = Configuration.standard
        configuration.schedule.workDays = 6
        configuration.schedule.dayStartHour = 8.5
        configuration.appearance.segmentWidth = 10
        configuration.appearance.highThreshold = 90
        configuration.appearance.goalColor = HexColor(hex: "#AABBCC")
        configuration.save(to: defaults)

        #expect(Configuration.load(from: defaults) == configuration)
    }
}

@Test func resetRemovesEverySetting() {
    withDefaults { defaults in
        for key in Configuration.keys {
            defaults.set("1", forKey: key)
        }
        defaults.set("unrelated", forKey: "NSStatusItem Preferred Position")

        Configuration.reset(in: defaults)

        #expect(Configuration.keys.allSatisfy { defaults.object(forKey: $0) == nil })
        #expect(Configuration.load(from: defaults) == .standard)
        // Only the Week HP settings are removed
        #expect(defaults.string(forKey: "NSStatusItem Preferred Position") == "unrelated")
    }
}
