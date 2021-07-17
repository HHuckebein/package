import Foundation
import XCTest

// Inspired by SwiftLint Source

import PackageFramework

enum Tests {
    static var resourcesPath: String {
        URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .appendingPathComponent("Resources")
            .path
            .absolutePathRepresentation().bridged.standardizingPath
    }
}

extension XCTestCase {
    /// Returns path to the built products directory.
    static var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }

   var testResourcesPath: String { Tests.resourcesPath }

    static func resourcePathForFile(_ filename: String) -> String? {
        #if SWIFT_PACKAGE
        let filePath = Bundle.module.url(forResource: filename, withExtension: nil)!.path
        #else
        let filePath = "\(testResourcesPath)/\(filename)"
        #endif

        return SwiftLintFile(path: filePath)?.path
    }

    var tmpDirectoryURL: URL { FileManager.default.temporaryDirectory }
}
