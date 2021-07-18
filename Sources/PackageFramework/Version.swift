import Foundation

public struct Version {
    let version: (major: Int, minor: Int, patch: Int)
    let isDevelopment: Bool

    var major: Int { version.major }
    var minor: Int { version.minor }
    var patch: Int { version.patch }

    public var displayString: String {
        var result = "\(major).\(minor).\(patch)"
        if isDevelopment { result += "-dev" }
        result += " (\(buildIdentifier))"
        return result
    }
}

public extension Version {
    static let current = Version(version: (0, 0, 1), isDevelopment: false)
}

private extension Version {
    var buildIdentifier: String { "de98a67" }
}
