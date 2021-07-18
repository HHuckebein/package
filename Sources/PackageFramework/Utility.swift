import Foundation
import SourceKittenFramework

public enum Utility {
    public enum Constants {
        static let minVersion = "5.3"
        static let expectedLocalPathExtension = "xcframework"
        static let expectedRemotePathExtension = "zip"
    }

    // MARK: - Directory Operations

    /// Creates the directory including intermediate directories if needed.
    /// - Parameter url: The url.
    /// - Returns: Wether the directory could be created.
    public static func createDirectoryIfNeeded(url: URL) -> Bool {
        let targetDirURL = URL(fileURLWithPath: url.deletingLastPathComponent().absoluteString, isDirectory: true)
        do {
           try FileManager.default.createDirectory(at: targetDirURL, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch {
            print("PackageFramework Error: output-directory creation failed with \(error.localizedDescription)")
            return false
        }
    }

    /// Convert contents of URL into a File object.
    /// - Parameter packageURL: The URL to the Package.swift file.
    /// - Returns: A File object if conversion succeeded.
    public static func file(from packageURL: URL) -> File? {
        let url = URL(fileURLWithPath: packageURL.absoluteString)
        guard let string = try? String(contentsOf: url, encoding: .utf8) else {
            print("PackageFramework Error: Package.swift file missing at \(packageURL.path)")
            return nil
        }
        return File(contents: string)
    }

    /// The Syntax Structure of the Package.swift source code.
    /// - Parameter file: The input File object representing the Package.swift source.
    /// - Returns: The syntax structure.
    public static func syntaxStructure(from file: File) -> SyntaxStructure? {
        do {
            let structure = try Structure(file: file)
            if let jsonData = structure.description.data(using: .utf8) {
                return try JSONDecoder().decode(SyntaxStructure.self, from: jsonData)
            } else {
                print("PackageFramework Error: Converting Structure.description into data(using:) failed")
                return nil
            }
        } catch {
            print("PackageFramework Error: Decoding SyntaxStructure failed with \(error.localizedDescription)")
            return nil
        }
    }

    /// Create a target url from the outputDirectory. Adds "Package.swift" if needed.
    /// - Parameter outputDirectory: The output directory as URL.
    /// - Returns: The fully specified url (including Filename and extension).
    public static func targetURL(outputDirectory: URL) -> URL {
        let path = outputDirectory.absoluteString.bridged.absolutePathRepresentation()
        var url = URL(fileURLWithPath: path)
        if url.pathExtension.isEmpty {
            url.appendPathComponent("Package.swift")
        }
        return url
    }

    /// Conformance checks of the remote url. (Scheme must be https: or http: . Extension must be .zip)
    /// - Parameter url: The URL.
    /// - Returns: Wether path passed conformance checks.
    public static func checkRemoteURL(_ url: URL) -> Bool {
        guard let scheme = url.scheme, scheme == "https" || scheme == "http" else {
            print("PackageFramework Error: URL failure: scheme: \(url.scheme ?? "--") is not allowed here. Use http or https.")
            return false
        }

        guard url.pathExtension == Constants.expectedRemotePathExtension else {
            print("PackageFramework Error: URL failure: Expected \(Constants.expectedRemotePathExtension) extension but found \(url.pathExtension).")
            return false
        }
        return true
    }

    /// Conformance checks of the local path. (Must be turned into an URL. Must not contain a scheme. Path extension must be .xcframework)
    /// - Parameter path: The path.
    /// - Returns: Wether path passed conformance checks.
    public static func checkLocalPath(_ path: String) -> Bool {
        guard let url = URL(string: path) else {
            print("PackageFramework Error: couldn't create url from \(path)")
            return false
        }

        guard url.scheme == nil else {
            print("PackageFramework Error: \(url.scheme ?? "--") is not allowed here.")
            return false
        }
        guard url.pathExtension == Constants.expectedLocalPathExtension else {
            print("PackageFramework Error: Expected \(Constants.expectedLocalPathExtension) but found \(url.pathExtension).")
            return false
        }
        return true
    }

    /// Writes or outputs the new Package.swift file.
    /// - Parameters:
    ///   - content: The string containing the original package infor plus the binary target information.
    ///   - outputDirectory: The target directory.
    ///   - debug: The flag determines wether the content is written to the `outputDirectory` or the console.
    ///   - verbose: Logs a successful write.
    public static func save(_ content: String, to outputDirectory: URL, debug: Bool, verbose: Bool) {
        // For Testing purpose print string instead of writing it to a file
        if debug {
            print("\(content)")
        } else {
            guard createDirectoryIfNeeded(url: outputDirectory) else { return }
            let targetURL = Utility.targetURL(outputDirectory: outputDirectory)

            do {
                try content.write(to: targetURL, atomically: true, encoding: .utf8)
                if verbose { print("PackageFramework Info: Writing content to \(targetURL.absoluteString) succeeded.") }
            } catch {
                print("PackageFramework Error: Writing content to \(targetURL.absoluteString) failed with \(error.localizedDescription)")
            }
        }
    }

    /// Checks wether the swift-tools-version is greater or equal to 5.3.
    /// - Parameters:
    ///   - file: The File.
    ///   - verbose: Logs the found swift-tools-version if true.
    /// - Returns: Returns wether the swift tools version supports binary targets.
    public static func supportsBinaryTarget(file: File, verbose: Bool) -> Bool {
        guard let version = file.swiftToolsVersion else { return false }

        if verbose { print("PackageFramework Info: swift-tools-version: \(version)") }

        switch version.versionCompare(Constants.minVersion) {
            case .orderedAscending:
                print("PackageFramework Error: swift-tools-version must be greater 5.2 (current:  \(version))")
                return false
            case .orderedSame, .orderedDescending:
                return true
        }
    }
}
