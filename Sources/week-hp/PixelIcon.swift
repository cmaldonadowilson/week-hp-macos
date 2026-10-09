// SPDX-License-Identifier: GPL-2.0-or-later
//

import AppKit

/// Pixel-art icons of the GNOME extension (icons/*.svg): rectangles on a 7×7 grid.
enum PixelIcon {
    case heart
    case star

    private static let gridSize: CGFloat = 7

    // x, y, width, height in grid pixels, from the top left corner
    private var rects: [(CGFloat, CGFloat, CGFloat, CGFloat)] {
        switch self {
        case .heart:
            return [(1, 0, 2, 1), (4, 0, 2, 1), (0, 1, 7, 2), (1, 3, 5, 1), (2, 4, 3, 1), (3, 5, 1, 1)]
        case .star:
            return [(3, 0, 1, 2), (0, 2, 7, 1), (1, 3, 5, 1), (2, 4, 3, 1),
                    (1, 5, 2, 1), (4, 5, 2, 1), (1, 6, 1, 1), (5, 6, 1, 1)]
        }
    }

    // The heart is 6 pixels tall: its SVG viewBox moves it half a pixel down to center it
    private var verticalOffset: CGFloat {
        self == .heart ? 0.5 : 0
    }

    /// Draws the icon filling the square `rect` of a flipped (top-left origin) context.
    func draw(in rect: NSRect, color: NSColor) {
        let pixel = rect.width / Self.gridSize
        color.setFill()
        for (x, y, width, height) in rects {
            NSRect(x: rect.minX + x * pixel,
                   y: rect.minY + (y + verticalOffset) * pixel,
                   width: width * pixel,
                   height: height * pixel).fill()
        }
    }

    func image(size: CGFloat, color: NSColor) -> NSImage {
        NSImage(size: NSSize(width: size, height: size), flipped: true) { rect in
            draw(in: rect, color: color)
            return true
        }
    }
}
