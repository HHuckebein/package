import SourceKittenFramework

public extension File {
    enum Constants {
        static let versionStringIdentifier = "swift-tools-version:"
    }

    var swiftToolsVersion: String? {
        guard let line = lines.first else {
            Log.error(destination: .package, message: "Couldn't find swift tools version")
            return nil
        }
        return line.content.extract(from: Constants.versionStringIdentifier, to: "\n")
    }
}
