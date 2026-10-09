// SPDX-License-Identifier: GPL-2.0-or-later
//

import Foundation

/// A color as stored in `defaults`: "#RRGGBB".
public struct HexColor: Equatable, Hashable, Sendable {
    public var red: UInt8
    public var green: UInt8
    public var blue: UInt8

    public init(red: UInt8, green: UInt8, blue: UInt8) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    /// Parses "#e63946" or "e63946", in any case.
    public init?(hex: String) {
        let digits = hex.hasPrefix("#") ? hex.dropFirst() : Substring(hex)
        guard digits.count == 6, let value = UInt32(digits, radix: 16) else {
            return nil
        }
        self.init(red: UInt8(value >> 16 & 0xFF), green: UInt8(value >> 8 & 0xFF), blue: UInt8(value & 0xFF))
    }

    public var hex: String {
        String(format: "#%02X%02X%02X", red, green, blue)
    }
}

/// How the bar looks: the width of its segments, the progress where it turns
/// yellow and green, and the colors chosen by the user.
public struct BarAppearance: Equatable, Sendable {
    public static let standard = BarAppearance()
    public static let segmentWidthRange = 4...40

    // Colors of the GNOME extension's stylesheet.css
    public static let defaultFillLowColor = HexColor(red: 0xE6, green: 0x39, blue: 0x46)
    public static let defaultFillMidColor = HexColor(red: 0xF4, green: 0xC4, blue: 0x30)
    public static let defaultFillHighColor = HexColor(red: 0x3D, green: 0xDC, blue: 0x55)
    // The default goal color gets darker on a light menu bar to stay visible
    public static let defaultGoalColor = HexColor(red: 0xFF, green: 0xD7, blue: 0x00)
    public static let defaultGoalColorOnLight = HexColor(red: 0xB8, green: 0x86, blue: 0x0B)

    // Keys for `defaults write com.cmaldonadowilson.weekhp <key> <value>`
    public static let segmentWidthKey = "segmentWidth"
    public static let midThresholdKey = "midThreshold"
    public static let highThresholdKey = "highThreshold"
    public static let fillLowColorKey = "fillLowColor"
    public static let fillMidColorKey = "fillMidColor"
    public static let fillHighColorKey = "fillHighColor"
    public static let goalColorKey = "goalColor"
    public static let compactKey = "compactMode"

    /// Width of each day segment, in points
    public var segmentWidth = 14
    /// Total weekly progress, in percent, where the bar turns from red to yellow
    public var midThreshold: Double = 40
    /// Total weekly progress, in percent, where the bar turns green
    public var highThreshold: Double = 80
    // Colors chosen by the user; nil means the default one
    public var fillLowColor: HexColor?
    public var fillMidColor: HexColor?
    public var fillHighColor: HexColor?
    public var goalColor: HexColor?
    /// Shows only the icon and the bar, without the text, to take less room in the menu bar
    public var compact = false

    public init() {}

    public var hasValidSegmentWidth: Bool {
        Self.segmentWidthRange.contains(segmentWidth)
    }

    /// Both within 0...100, yellow before green.
    public var hasValidThresholds: Bool {
        [midThreshold, highThreshold].allSatisfy { $0.isFinite && (0...100).contains($0) }
            && midThreshold < highThreshold
    }

    public func level(for progress: WeekProgress) -> WeekProgress.Level {
        WeekProgress.Level(total: progress.total, midThreshold: midThreshold, highThreshold: highThreshold)
    }

    /// Reads the appearance set by the user. An invalid segment width, pair of
    /// thresholds or color falls back to its default.
    public static func load(from defaults: UserDefaults) -> BarAppearance {
        var appearance = BarAppearance()

        let width = defaults.number(forKey: segmentWidthKey, fallback: Double(standard.segmentWidth))
        if width.rounded() == width, Double(segmentWidthRange.lowerBound)...Double(segmentWidthRange.upperBound) ~= width {
            appearance.segmentWidth = Int(width)
        }

        var thresholds = appearance
        thresholds.midThreshold = defaults.number(forKey: midThresholdKey, fallback: standard.midThreshold)
        thresholds.highThreshold = defaults.number(forKey: highThresholdKey, fallback: standard.highThreshold)
        if thresholds.hasValidThresholds {
            appearance.midThreshold = thresholds.midThreshold
            appearance.highThreshold = thresholds.highThreshold
        }

        func color(_ key: String) -> HexColor? {
            defaults.string(forKey: key).flatMap(HexColor.init(hex:))
        }
        appearance.fillLowColor = color(fillLowColorKey)
        appearance.fillMidColor = color(fillMidColorKey)
        appearance.fillHighColor = color(fillHighColorKey)
        appearance.goalColor = color(goalColorKey)
        // Also reads "true" or "YES" written by `defaults write` without -bool
        appearance.compact = defaults.bool(forKey: compactKey)
        return appearance
    }

    func save(to defaults: UserDefaults) {
        defaults.set(segmentWidth, forKey: Self.segmentWidthKey)
        defaults.set(midThreshold, forKey: Self.midThresholdKey)
        defaults.set(highThreshold, forKey: Self.highThresholdKey)
        defaults.set(compact, forKey: Self.compactKey)
        let colors = [
            Self.fillLowColorKey: fillLowColor,
            Self.fillMidColorKey: fillMidColor,
            Self.fillHighColorKey: fillHighColor,
            Self.goalColorKey: goalColor,
        ]
        for (key, color) in colors {
            if let color {
                defaults.set(color.hex, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
}
