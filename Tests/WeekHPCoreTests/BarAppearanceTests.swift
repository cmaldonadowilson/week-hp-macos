// SPDX-License-Identifier: GPL-2.0-or-later
//

import Foundation
import Testing
@testable import WeekHPCore

@Test(arguments: [
    ("#e63946", HexColor(red: 0xE6, green: 0x39, blue: 0x46)),
    ("#E63946", HexColor(red: 0xE6, green: 0x39, blue: 0x46)),
    ("3ddc55", HexColor(red: 0x3D, green: 0xDC, blue: 0x55)),
    ("#000000", HexColor(red: 0, green: 0, blue: 0)),
])
func colorsParseFromHex(hex: String, expected: HexColor) {
    #expect(HexColor(hex: hex) == expected)
    #expect(HexColor(hex: expected.hex) == expected)
}

@Test(arguments: ["", "#", "#fff", "#e6394", "#e639466", "#gg3946", "rgb(230,57,70)"])
func invalidColorsAreRejected(hex: String) {
    #expect(HexColor(hex: hex) == nil)
}

@Test func standardAppearanceMatchesTheGnomeExtension() {
    let standard = BarAppearance.standard
    #expect(standard.segmentWidth == 14)
    #expect(standard.midThreshold == 40)
    #expect(standard.highThreshold == 80)
    #expect([standard.fillLowColor, standard.fillMidColor, standard.fillHighColor, standard.goalColor] == [nil, nil, nil, nil])
    #expect(BarAppearance.defaultFillLowColor.hex == "#E63946")
    #expect(BarAppearance.defaultFillMidColor.hex == "#F4C430")
    #expect(BarAppearance.defaultFillHighColor.hex == "#3DDC55")
    #expect(BarAppearance.defaultGoalColor.hex == "#FFD700")
}

@Test func loadWithoutAppearanceSettingsGivesTheStandardOne() {
    withDefaults { defaults in
        #expect(BarAppearance.load(from: defaults) == .standard)
    }
}

@Test func loadReadsAllAppearanceKeys() {
    withDefaults { defaults in
        defaults.set(20, forKey: BarAppearance.segmentWidthKey)
        defaults.set(30, forKey: BarAppearance.midThresholdKey)
        defaults.set(70, forKey: BarAppearance.highThresholdKey)
        defaults.set("#112233", forKey: BarAppearance.fillLowColorKey)
        defaults.set("#445566", forKey: BarAppearance.fillMidColorKey)
        defaults.set("#778899", forKey: BarAppearance.fillHighColorKey)
        defaults.set("#aabbcc", forKey: BarAppearance.goalColorKey)

        let appearance = BarAppearance.load(from: defaults)
        #expect(appearance.segmentWidth == 20)
        #expect(appearance.midThreshold == 30)
        #expect(appearance.highThreshold == 70)
        #expect(appearance.fillLowColor?.hex == "#112233")
        #expect(appearance.fillMidColor?.hex == "#445566")
        #expect(appearance.fillHighColor?.hex == "#778899")
        #expect(appearance.goalColor?.hex == "#AABBCC")
    }
}

@Test(arguments: ["3", "41", "14.5", "wide"])
func invalidSegmentWidthFallsBack(value: String) {
    withDefaults { defaults in
        defaults.set(value, forKey: BarAppearance.segmentWidthKey)
        #expect(BarAppearance.load(from: defaults).segmentWidth == 14)
    }
}

@Test(arguments: [(80.0, 40.0), (50.0, 50.0), (-5.0, 80.0), (40.0, 120.0)])
func invalidThresholdsFallBackTogether(mid: Double, high: Double) {
    withDefaults { defaults in
        defaults.set(mid, forKey: BarAppearance.midThresholdKey)
        defaults.set(high, forKey: BarAppearance.highThresholdKey)
        let appearance = BarAppearance.load(from: defaults)
        #expect(appearance.midThreshold == 40)
        #expect(appearance.highThreshold == 80)
    }
}

@Test func oneInvalidValueDoesNotResetTheOthers() {
    withDefaults { defaults in
        defaults.set(99, forKey: BarAppearance.segmentWidthKey)
        defaults.set(30, forKey: BarAppearance.midThresholdKey)
        defaults.set("not a color", forKey: BarAppearance.goalColorKey)
        defaults.set("#112233", forKey: BarAppearance.fillLowColorKey)

        let appearance = BarAppearance.load(from: defaults)
        #expect(appearance.segmentWidth == 14)
        #expect(appearance.midThreshold == 30)
        #expect(appearance.goalColor == nil)
        #expect(appearance.fillLowColor?.hex == "#112233")
    }
}

@Test func saveRemovesTheColorsLeftAtTheirDefault() {
    withDefaults { defaults in
        defaults.set("#112233", forKey: BarAppearance.goalColorKey)
        var appearance = BarAppearance.load(from: defaults)
        appearance.goalColor = nil
        appearance.fillMidColor = HexColor(hex: "#445566")
        appearance.save(to: defaults)

        #expect(defaults.object(forKey: BarAppearance.goalColorKey) == nil)
        #expect(defaults.string(forKey: BarAppearance.fillMidColorKey) == "#445566")
        #expect(BarAppearance.load(from: defaults) == appearance)
    }
}
