// SPDX-License-Identifier: GPL-2.0-or-later
//

import AppKit
import WeekHPCore

/// Owns the menu bar item: updates the bar every minute and after the Mac
/// wakes up or the clock changes.
@MainActor
final class StatusController: NSObject, NSApplicationDelegate {
    private let tr = Translations()
    private var statusItem: NSStatusItem!
    private var barView: HealthBarView!
    private var timer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        // Remembers the position chosen with ⌘-drag
        statusItem.autosaveName = WeekHP.bundleIdentifier
        statusItem.menu = makeMenu()

        barView = HealthBarView(reservedTexts: tr.longestStatusTexts)
        if let button = statusItem.button {
            barView.frame = button.bounds
            barView.autoresizingMask = [.width, .height]
            button.addSubview(barView)
        }

        let workspaceCenter = NSWorkspace.shared.notificationCenter
        workspaceCenter.addObserver(self, selector: #selector(clockDidChange),
                                    name: NSWorkspace.didWakeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(clockDidChange),
                                               name: .NSSystemClockDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(clockDidChange),
                                               name: .NSSystemTimeZoneDidChange, object: nil)

        update()
        scheduleTimer()
    }

    private func makeMenu() -> NSMenu {
        let menu = NSMenu()
        menu.addItem(withTitle: tr("About Week HP"), action: #selector(showAbout), keyEquivalent: "").target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: tr("Quit Week HP"), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        return menu
    }

    @objc private func update() {
        // Read every time, so `defaults write` changes show up within a minute
        let hours = WorkHours.load(from: WeekHP.userDefaults)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        let progress = WeekProgress(at: Date(), calendar: calendar, hours: hours)
        let text = tr.status(for: progress)

        barView.show(progress, text: text)
        statusItem.length = barView.contentWidth
        statusItem.button?.setAccessibilityLabel("\(WeekHP.name): \(text)")
    }

    // Fires at the start of every minute, when the percentage may change
    private func scheduleTimer() {
        timer?.invalidate()
        let nextMinute = Calendar.current.nextDate(after: Date(), matching: DateComponents(second: 0),
                                                   matchingPolicy: .nextTime) ?? Date(timeIntervalSinceNow: 60)
        let timer = Timer(fireAt: nextMinute, interval: 60, target: self, selector: #selector(update),
                          userInfo: nil, repeats: true)
        timer.tolerance = 1
        // .common keeps it running while the menu is open
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    @objc private func clockDidChange() {
        NSTimeZone.resetSystemTimeZone()
        update()
        scheduleTimer()
    }

    @objc private func showAbout() {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
        let credits = NSMutableAttributedString(
            string: tr("Official macOS port of Week HP by asterion.") + "\n",
            attributes: [.font: font, .paragraphStyle: paragraph, .foregroundColor: NSColor.labelColor])
        credits.append(NSAttributedString(
            string: WeekHP.originalProjectURL.absoluteString,
            attributes: [.font: font, .paragraphStyle: paragraph, .link: WeekHP.originalProjectURL]))

        // A menu bar app is never active on its own; bring the panel to the front
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(options: [
            .applicationName: WeekHP.name,
            .applicationVersion: WeekHP.version,
            .version: "",
            .applicationIcon: PixelIcon.heart.image(size: 128, color: Palette(isDark: true).heart),
            .credits: credits,
            NSApplication.AboutPanelOptionKey(rawValue: "Copyright"): "GPL-2.0-or-later",
        ])
    }
}
