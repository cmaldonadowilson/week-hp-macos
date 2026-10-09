// SPDX-License-Identifier: GPL-2.0-or-later
//

/// What `week-hp` does, from its command line options.
public enum LaunchCommand: Equatable, Sendable {
    case runApp
    case printStatus
    case printVersion
    case printHelp
    case unknownOption(String)

    public static let usage = """
        Usage: week-hp [--print | --version | --help]

        A retro health bar in the menu bar that fills up from Monday to Friday.
        With no options, Week HP opens in the menu bar.

          --print     Print the week progress, e.g. "Wed 52%", and exit
          --version   Print the version and exit
          --help      Show this help and exit

        Change the work schedule and the bar in Settings…, in the Week HP menu,
        or with `defaults write com.cmaldonadowilson.weekhp <key> <value>`.
        More at https://github.com/cmaldonadowilson/week-hp-macos
        """

    /// The first option decides. Single-dash arguments such as
    /// `-AppleLanguages "(fr)"` are left to the system.
    /// - Parameter arguments: the arguments, without the program name
    public init(arguments: [String]) {
        guard let option = arguments.first(where: { $0.hasPrefix("--") || $0 == "-h" }) else {
            self = .runApp
            return
        }
        switch option {
        case "--print":
            self = .printStatus
        case "--version":
            self = .printVersion
        case "--help", "-h":
            self = .printHelp
        default:
            self = .unknownOption(option)
        }
    }
}
