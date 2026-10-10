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
    private var settingsWindow: SettingsWindowController?
    private var compactItem: NSMenuItem!
    // Status and what is left of the day and the week, at the top of the menu
    private var detailItems: [NSMenuItem] = []

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
        menu.delegate = self
        // The details go above this separator, see showDetails(_:)
        menu.addItem(.separator())
        menu.addItem(withTitle: tr("About Week HP"), action: #selector(showAbout), keyEquivalent: "").target = self
        menu.addItem(withTitle: tr("Settings…"), action: #selector(showSettings), keyEquivalent: ",").target = self
        compactItem = menu.addItem(withTitle: tr("Compact Mode"), action: #selector(toggleCompactMode), keyEquivalent: "")
        compactItem.target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: tr("Quit Week HP"), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        return menu
    }

    @objc private func update() {
        // Reads the settings every time, so `defaults write` changes show up within a minute
        let configuration = Configuration.load()
        let progress = WeekProgress.current(schedule: configuration.schedule)
        let text = tr.status(for: progress)

        barView.show(progress, text: text, appearance: configuration.appearance)
        statusItem.length = barView.contentWidth
        statusItem.button?.toolTip = text
        statusItem.button?.setAccessibilityLabel("\(WeekHP.name): \(text)")
        showDetails([text] + tr.lines(for: .current(schedule: configuration.schedule)))
    }

    /// Replaces the lines at the top of the menu, which only give information.
    private func showDetails(_ lines: [String]) {
        guard let menu = statusItem.menu else {
            return
        }
        detailItems.forEach(menu.removeItem)
        detailItems = lines.map { line in
            let item = NSMenuItem(title: line, action: nil, keyEquivalent: "")
            item.isEnabled = false
            return item
        }
        for (index, item) in detailItems.enumerated() {
            menu.insertItem(item, at: index)
        }
    }

    @objc private func showSettings() {
        if settingsWindow == nil {
            // Changes show up in the bar right away
            settingsWindow = SettingsWindowController(tr: tr) { [weak self] in
                self?.update()
            }
        }
        settingsWindow?.show()
    }

    @objc private func toggleCompactMode() {
        // Only this key: the other settings keep their defaults
        let defaults = WeekHP.userDefaults
        defaults.set(!Configuration.load(from: defaults).appearance.compact, forKey: BarAppearance.compactKey)
        settingsWindow?.reload()
        update()
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

extension StatusController: NSMenuDelegate {
    // The compact mode may have changed in Settings or with `defaults write`
    func menuNeedsUpdate(_ menu: NSMenu) {
        compactItem.state = Configuration.load().appearance.compact ? .on : .off
    }
}
