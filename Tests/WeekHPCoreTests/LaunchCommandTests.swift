// SPDX-License-Identifier: GPL-2.0-or-later
//

import Testing
@testable import WeekHPCore

@Test(arguments: [
    ([], LaunchCommand.runApp),
    (["--print"], .printStatus),
    (["--version"], .printVersion),
    (["--help"], .printHelp),
    (["-h"], .printHelp),
    (["--bogus"], .unknownOption("--bogus")),
    (["--print", "--version"], .printStatus),
    // Settings passed to the system, e.g. to try another language
    (["-AppleLanguages", "(fr)"], .runApp),
    (["-AppleLanguages", "(fr)", "--print"], .printStatus),
])
func optionsPickTheCommand(arguments: [String], expected: LaunchCommand) {
    #expect(LaunchCommand(arguments: arguments) == expected)
}
