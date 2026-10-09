// SPDX-License-Identifier: GPL-2.0-or-later
//

import AppKit
import WeekHPCore

/// Pixel-art health bar with 5 segments (Monday to Friday), drawn inside the
/// status item button: icon, bar and status text.
final class HealthBarView: NSView {
    // Same sizes as stylesheet.css in the GNOME extension
    private enum Metrics {
        static let iconSize: CGFloat = 14
        static let spacing: CGFloat = 6
        static let border: CGFloat = 2
        static let padding: CGFloat = 2
        static let segmentWidth: CGFloat = 14
        static let segmentHeight: CGFloat = 10
        static let segmentSpacing: CGFloat = 2
        // Space at both ends of the status item
        static let edgeInset: CGFloat = 4

        static let frameWidth = 2 * (border + padding)
            + CGFloat(WeekProgress.workDays) * segmentWidth
            + CGFloat(WeekProgress.workDays - 1) * segmentSpacing
        static let frameHeight = 2 * (border + padding) + segmentHeight
    }

    private static let font = NSFont.monospacedSystemFont(ofSize: 12, weight: .bold)

    private var progress: WeekProgress
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

    var contentWidth: CGFloat {
        2 * Metrics.edgeInset + Metrics.iconSize + Metrics.spacing + Metrics.frameWidth + Metrics.spacing + textWidth
    }

    func show(_ progress: WeekProgress, text: String) {
        self.progress = progress
        self.text = text
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
        let palette = Palette(isDark: effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua)
        let complete = progress.isComplete
        var x = Metrics.edgeInset

        let iconRect = NSRect(x: x, y: centeredY(Metrics.iconSize), width: Metrics.iconSize, height: Metrics.iconSize)
        (complete ? PixelIcon.star : PixelIcon.heart).draw(in: iconRect, color: complete ? palette.gold : palette.heart)
        x += Metrics.iconSize + Metrics.spacing

        // Outer frame: solid 8/16-bit style border
        let frameRect = NSRect(x: x, y: centeredY(Metrics.frameHeight), width: Metrics.frameWidth, height: Metrics.frameHeight)
        palette.frameBorder.setFill()
        frameRect.fill()
        palette.frameBackground.setFill()
        frameRect.insetBy(dx: Metrics.border, dy: Metrics.border).fill()

        // Each segment is one day; the empty part stays dark
        let fillColor = palette.fill(for: progress.level)
        var segmentX = frameRect.minX + Metrics.border + Metrics.padding
        let segmentY = frameRect.minY + Metrics.border + Metrics.padding
        for day in progress.days {
            let segment = NSRect(x: segmentX, y: segmentY, width: Metrics.segmentWidth, height: Metrics.segmentHeight)
            palette.emptySegment.setFill()
            segment.fill()
            var filled = segment
            filled.size.width = (Metrics.segmentWidth * day).rounded()
            fillColor.setFill()
            filled.fill()
            segmentX += Metrics.segmentWidth + Metrics.segmentSpacing
        }
        x += Metrics.frameWidth + Metrics.spacing

        let attributes: [NSAttributedString.Key: Any] = [
            .font: Self.font,
            .foregroundColor: complete ? palette.gold : NSColor.labelColor,
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

/// Colors of stylesheet.css. The GNOME top panel is always dark; on a light
/// menu bar the frame border, heart and gold get darker to stay visible.
struct Palette {
    let heart: NSColor
    let gold: NSColor
    let frameBorder: NSColor
    let frameBackground = NSColor(hex: 0x1A1A1A)
    let emptySegment = NSColor(hex: 0x3A3A3A)

    init(isDark: Bool) {
        heart = NSColor(hex: isDark ? 0xFF4D6D : 0xE63946)
        gold = NSColor(hex: isDark ? 0xFFD700 : 0xB8860B)
        frameBorder = NSColor(hex: isDark ? 0xF0F0F0 : 0x1A1A1A)
    }

    // Like in games: red when low, yellow at half, green when nearly full
    func fill(for level: WeekProgress.Level) -> NSColor {
        switch level {
        case .low:
            return NSColor(hex: 0xE63946)
        case .mid:
            return NSColor(hex: 0xF4C430)
        case .high, .complete:
            return NSColor(hex: 0x3DDC55)
        }
    }
}

private extension NSColor {
    convenience init(hex: Int) {
        self.init(srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
                  green: CGFloat((hex >> 8) & 0xFF) / 255,
                  blue: CGFloat(hex & 0xFF) / 255,
                  alpha: 1)
    }
}
