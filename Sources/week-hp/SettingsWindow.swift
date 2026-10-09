// SPDX-License-Identifier: GPL-2.0-or-later
//
// The Settings window, with the options of the Cinnamon applet
// (asterion/week-hp-cinnamon). The app has no SwiftUI App to host a Settings
// scene, so the SwiftUI form lives in an AppKit window.

import AppKit
import SwiftUI
import WeekHPCore

@MainActor
final class SettingsWindowController {
    private let model: SettingsModel
    private let window: NSWindow

    /// - Parameter onChange: called after every change, already saved
    init(tr: Translations, onChange: @escaping () -> Void) {
        model = SettingsModel(onChange: onChange)
        let hosting = NSHostingController(rootView: SettingsView(model: model, tr: tr))
        hosting.sizingOptions = .preferredContentSize

        window = SettingsWindow(contentViewController: hosting)
        window.title = tr("Week HP Settings")
        window.styleMask = [.titled, .closable]
        window.isReleasedWhenClosed = false
        window.setContentSize(hosting.view.fittingSize)
        window.center()
    }

    func show() {
        // Shows what `defaults write` may have changed while the window was closed
        model.reload()
        // A menu bar app is never active on its own; bring the window to the front
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }
}

/// Closes with ⌘W, since a menu bar app has no menu to provide it.
private final class SettingsWindow: NSWindow {
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if event.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command,
           event.charactersIgnoringModifiers == "w" {
            performClose(nil)
            return true
        }
        return super.performKeyEquivalent(with: event)
    }
}

/// The configuration being edited, saved as soon as it changes.
@MainActor
final class SettingsModel: ObservableObject {
    @Published var configuration: Configuration {
        didSet {
            guard !isReloading, configuration != oldValue else {
                return
            }
            configuration.save()
            onChange()
        }
    }

    private let onChange: () -> Void
    private var isReloading = false

    init(onChange: @escaping () -> Void) {
        configuration = Configuration.load()
        self.onChange = onChange
    }

    func reload() {
        isReloading = true
        configuration = Configuration.load()
        isReloading = false
    }

    func restoreDefaults() {
        Configuration.reset()
        reload()
        onChange()
    }
}

struct SettingsView: View {
    @ObservedObject var model: SettingsModel
    let tr: Translations

    // Steps of the steppers: half hours and 5% of progress
    private let hourStep = 0.5
    private let thresholdStep = 5.0

    private var schedule: WorkSchedule { model.configuration.schedule }
    private var appearance: BarAppearance { model.configuration.appearance }

    var body: some View {
        Form {
            Section(tr("Work schedule")) {
                row(tr("Work days per week"), value: tr.workDays(schedule.workDays),
                    help: tr("Number of segments in the bar. 5 means Monday to Friday.")) {
                    Stepper("", value: $model.configuration.schedule.workDays, in: WorkSchedule.workDaysRange)
                }
                // Each day must end after it starts, so the ranges depend on each other
                row(tr("Day starts at"), value: Translations.clockTime(schedule.dayStartHour),
                    help: tr("Before this hour a day counts as empty. Use 00:00 to count from midnight.")) {
                    Stepper("", value: $model.configuration.schedule.dayStartHour,
                            in: range(0, min(schedule.dayEndHour, schedule.lastDayEndHour) - hourStep), step: hourStep)
                }
                row(tr("Day is complete at"), value: Translations.clockTime(schedule.dayEndHour),
                    help: tr("After this hour a day counts as full. Use 24:00 to count until midnight.")) {
                    Stepper("", value: $model.configuration.schedule.dayEndHour,
                            in: range(schedule.dayStartHour + hourStep, 24), step: hourStep)
                }
                row(tr("Last work day ends at"), value: Translations.clockTime(schedule.lastDayEndHour),
                    help: tr("The weekly goal is reached at this hour on the last work day (Friday by default). Keep it later than the day start hour.")) {
                    Stepper("", value: $model.configuration.schedule.lastDayEndHour,
                            in: range(schedule.dayStartHour + hourStep, 24), step: hourStep)
                }
            }

            Section(tr("Bar appearance")) {
                row(tr("Segment width"), value: "\(appearance.segmentWidth) px",
                    help: tr("Width of each day segment in the bar.")) {
                    Stepper("", value: $model.configuration.appearance.segmentWidth, in: BarAppearance.segmentWidthRange)
                }
                // Yellow must come before green
                row(tr("Turns yellow at"), value: tr.percentage(Int(appearance.midThreshold)),
                    help: tr("Total weekly progress where the bar changes from red to yellow. Keep it below the green threshold.")) {
                    Stepper("", value: $model.configuration.appearance.midThreshold,
                            in: range(0, appearance.highThreshold - thresholdStep), step: thresholdStep)
                }
                row(tr("Turns green at"), value: tr.percentage(Int(appearance.highThreshold)),
                    help: tr("Total weekly progress where the bar changes to green. Keep it above the yellow threshold.")) {
                    Stepper("", value: $model.configuration.appearance.highThreshold,
                            in: range(appearance.midThreshold + thresholdStep, 100), step: thresholdStep)
                }
            }

            Section(tr("Colors")) {
                colorPicker(tr("Fill color: low progress"), \.fillLowColor, BarAppearance.defaultFillLowColor,
                            help: tr("Color of the fill while progress is below the yellow threshold."))
                colorPicker(tr("Fill color: mid progress"), \.fillMidColor, BarAppearance.defaultFillMidColor,
                            help: tr("Color of the fill between the yellow and green thresholds."))
                colorPicker(tr("Fill color: high progress"), \.fillHighColor, BarAppearance.defaultFillHighColor,
                            help: tr("Color of the fill from the green threshold until the goal."))
                colorPicker(tr("Goal color"), \.goalColor, BarAppearance.defaultGoalColor,
                            help: tr("Color of the star and the GOAL! message when the week is complete."))
            }

            Section {
                HStack {
                    Spacer()
                    Button(tr("Restore default values")) {
                        model.restoreDefaults()
                    }
                    .help(tr("Set every option back to its original value: schedule, bar appearance and colors."))
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 460)
    }

    private func row<Control: View>(_ title: String, value: String, help: String,
                                    @ViewBuilder control: () -> Control) -> some View {
        LabeledContent(title) {
            HStack {
                Text(value)
                    .monospacedDigit()
                control()
                    .labelsHidden()
            }
        }
        .help(help)
    }

    private func colorPicker(_ title: String, _ keyPath: WritableKeyPath<BarAppearance, HexColor?>,
                             _ defaultColor: HexColor, help: String) -> some View {
        let selection = Binding<Color>(
            get: { Color(nsColor: NSColor(model.configuration.appearance[keyPath: keyPath] ?? defaultColor)) },
            set: { model.configuration.appearance[keyPath: keyPath] = HexColor(NSColor($0)) }
        )
        return ColorPicker(title, selection: selection, supportsOpacity: false)
            .help(help)
    }

    /// A range that is never empty, even when the values that bound it are too close.
    private func range(_ lower: Double, _ upper: Double) -> ClosedRange<Double> {
        lower...max(lower, upper)
    }
}
