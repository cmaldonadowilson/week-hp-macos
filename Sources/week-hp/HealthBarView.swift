// SPDX-License-Identifier: GPL-2.0-or-later
//

import AppKit
import WeekHPCore

/// Pixel-art health bar with one segment per work day, drawn inside the
/// status item button: icon, bar and status text.
final class HealthBarView: NSView {
    // Same sizes as stylesheet.css in the GNOME extension; the segment width comes from the settings
    private enum Metrics {
        static let iconSize: CGFloat = 14
        static let spacing: CGFloat = 6
        static let border: CGFloat = 2
        static let padding: CGFloat = 2
        static let segmentHeight: CGFloat = 10
        static let segmentSpacing: CGFloat = 2
        // Space at both ends of the status item
        static let edgeInset: CGFloat = 4

        static let frameHeight = 2 * (border + padding) + segmentHeight

        static func frameWidth(segments: Int, segmentWidth: CGFloat) -> CGFloat {
            2 * (border + padding) + CGFloat(segments) * segmentWidth + CGFloat(max(segments - 1, 0)) * segmentSpacing
        }
    }

    private static let font = NSFont.monospacedSystemFont(ofSize: 12, weight: .bold)

    private var progress: WeekProgress
    private var barAppearance = BarAppearance.standard
    private var text = ""
    // Room for the widest text, so the item keeps its width as the percentage changes
    private let textWidth: CGFloat

    /// - Parameter reservedTexts: every text the view may show, to fix its width
    init(reservedTexts: [String]) {
        progress = WeekProgress(at: Date())
        textWidth = ceil(reservedTexts.map { Self.size(of: $0).width }.max() ?? 0)
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    private var frameWidth: CGFloat {
        Metrics.frameWidth(segments: progress.days.count, segmentWidth: CGFloat(barAppearance.segmentWidth))
    }

    var contentWidth: CGFloat {
        let iconAndBar = 2 * Metrics.edgeInset + Metrics.iconSize + Metrics.spacing + frameWidth
        // The compact mode leaves the text to the tooltip
        return barAppearance.compact ? iconAndBar : iconAndBar + Metrics.spacing + textWidth
    }

    func show(_ progress: WeekProgress, text: String, appearance: BarAppearance) {
        self.progress = progress
        self.text = text
        barAppearance = appearance
        needsDisplay = true
    }

    override var isFlipped: Bool { true }

    // Clicks go to the status item button, which opens the menu
    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        let isDark = effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        let palette = Palette(isDark: isDark, appearance: barAppearance)
        let complete = progress.isComplete
        var x = Metrics.edgeInset

        let iconRect = NSRect(x: x, y: centeredY(Metrics.iconSize), width: Metrics.iconSize, height: Metrics.iconSize)
        (complete ? PixelIcon.star : PixelIcon.heart).draw(in: iconRect, color: complete ? palette.goal : palette.heart)
        x += Metrics.iconSize + Metrics.spacing

        // Outer frame: solid 8/16-bit style border
        let frameRect = NSRect(x: x, y: centeredY(Metrics.frameHeight), width: frameWidth, height: Metrics.frameHeight)
        palette.frameBorder.setFill()
        frameRect.fill()
        palette.frameBackground.setFill()
        frameRect.insetBy(dx: Metrics.border, dy: Metrics.border).fill()

        // Each segment is one day; the empty part stays dark
        let segmentWidth = CGFloat(barAppearance.segmentWidth)
        let fillColor = palette.fill(for: barAppearance.level(for: progress))
        var segmentX = frameRect.minX + Metrics.border + Metrics.padding
        let segmentY = frameRect.minY + Metrics.border + Metrics.padding
        for day in progress.days {
            let segment = NSRect(x: segmentX, y: segmentY, width: segmentWidth, height: Metrics.segmentHeight)
            palette.emptySegment.setFill()
            segment.fill()
            var filled = segment
            filled.size.width = (segmentWidth * day).rounded()
            fillColor.setFill()
            filled.fill()
            segmentX += segmentWidth + Metrics.segmentSpacing
        }
        x += frameWidth + Metrics.spacing

        guard !barAppearance.compact else {
            return
        }
        let attributes: [NSAttributedString.Key: Any] = [
            .font: Self.font,
            .foregroundColor: complete ? palette.goal : NSColor.labelColor,
        ]
        let textHeight = Self.size(of: text).height
        (text as NSString).draw(at: NSPoint(x: x, y: centeredY(textHeight)), withAttributes: attributes)
    }

    private func centeredY(_ height: CGFloat) -> CGFloat {
        ((bounds.height - height) / 2).rounded()
    }

    private static func size(of text: String) -> NSSize {
        (text as NSString).size(withAttributes: [.font: font])
    }
}

/// Colors of stylesheet.css, or the ones chosen in the settings. The GNOME top
/// panel is always dark; on a light menu bar the frame border, heart and default
/// goal color get darker to stay visible. Colors chosen by the user are used as is.
struct Palette {
    let heart: NSColor
    let goal: NSColor
    let frameBorder: NSColor
    let frameBackground = NSColor(hex: 0x1A1A1A)
    let emptySegment = NSColor(hex: 0x3A3A3A)
    private let fillLow: NSColor
    private let fillMid: NSColor
    private let fillHigh: NSColor

    init(isDark: Bool, appearance: BarAppearance = .standard) {
        heart = NSColor(hex: isDark ? 0xFF4D6D : 0xE63946)
        frameBorder = NSColor(hex: isDark ? 0xF0F0F0 : 0x1A1A1A)
        goal = NSColor(appearance.goalColor
            ?? (isDark ? BarAppearance.defaultGoalColor : BarAppearance.defaultGoalColorOnLight))
        fillLow = NSColor(appearance.fillLowColor ?? BarAppearance.defaultFillLowColor)
        fillMid = NSColor(appearance.fillMidColor ?? BarAppearance.defaultFillMidColor)
        fillHigh = NSColor(appearance.fillHighColor ?? BarAppearance.defaultFillHighColor)
    }

    // Like in games: red when low, yellow at half, green when nearly full
    func fill(for level: WeekProgress.Level) -> NSColor {
        switch level {
        case .low:
            return fillLow
        case .mid:
            return fillMid
        case .high, .complete:
            return fillHigh
        }
    }
}

extension NSColor {
    convenience init(_ color: HexColor) {
        self.init(srgbRed: CGFloat(color.red) / 255, green: CGFloat(color.green) / 255,
                  blue: CGFloat(color.blue) / 255, alpha: 1)
    }

    fileprivate convenience init(hex: Int) {
        self.init(HexColor(red: UInt8(hex >> 16 & 0xFF), green: UInt8(hex >> 8 & 0xFF), blue: UInt8(hex & 0xFF)))
    }
}

extension HexColor {
    /// The color in sRGB, e.g. from the color picker of the Settings window.
    init?(_ color: NSColor) {
        guard let srgb = color.usingColorSpace(.sRGB) else {
            return nil
        }
        func channel(_ value: CGFloat) -> UInt8 {
            UInt8((min(max(value, 0), 1) * 255).rounded())
        }
        self.init(red: channel(srgb.redComponent), green: channel(srgb.greenComponent), blue: channel(srgb.blueComponent))
    }
}
