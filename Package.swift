// swift-tools-version:5.9
// SPDX-License-Identifier: GPL-2.0-or-later
//
// Tools version 5.9 keeps the package buildable with the Command Line Tools
// available on macOS 13 (Swift 5.9 / Xcode 15).

import PackageDescription

let package = Package(
    name: "week-hp",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(name: "week-hp", targets: ["week-hp"]),
    ],
    targets: [
        // Week progress logic, independent from the UI
        .target(name: "WeekHPCore"),
        // Menu bar app and command line entry point
        .executableTarget(
            name: "week-hp",
            dependencies: ["WeekHPCore"]
        ),
        // Swift Testing: needs Swift 6 (Command Line Tools 16 or later),
        // only to run the tests, not to build the app
        .testTarget(
            name: "WeekHPCoreTests",
            dependencies: ["WeekHPCore"]
        ),
    ]
)
