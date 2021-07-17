import os

public enum Log {
    public enum Destination {
        case package
        case framework
    }
    static var subsystem = "de.berndrabe.package"

    // executable specific logs
    static let package = OSLog(subsystem: subsystem, category: "package")

    // Utitilites related logs
    static let framework = OSLog(subsystem: subsystem, category: "framework")

    @available(OSX 11.0, *)
    private static var packageLogger = Logger(package)
    @available(OSX 11.0, *)
    private static var frameworkLogger = Logger(framework)

    public static func error(destination: Destination, message: String) {
        if #available(OSX 11.0, *) {
            switch destination {
            case .package:  packageLogger.error("\(message, privacy: .public)")
            case .framework:  frameworkLogger.error("\(message, privacy: .public)")
            }
        }
    }

    public static func debug(destination: Destination, message: String) {
        if #available(OSX 11.0, *) {
            switch destination {
            case .package:  packageLogger.debug("\(message, privacy: .public)")
            case .framework:  frameworkLogger.debug("\(message, privacy: .public)")
            }
        }
    }

    public static func info(destination: Destination, message: String) {
        if #available(OSX 11.0, *) {
            switch destination {
            case .package:  packageLogger.info("\(message, privacy: .public)")
            case .framework:  frameworkLogger.info("\(message, privacy: .public)")
            }
        }
    }
}
