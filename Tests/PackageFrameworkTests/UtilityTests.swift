import XCTest
import SourceKittenFramework
@testable import PackageFramework

final class UtilityTests: XCTestCase {
    static var allTests = [
        ("test_fileFrom", test_fileFrom),
        ("test_syntaxStructureFrom", test_syntaxStructureFrom),
        ("test_targetURL", test_targetURL),
        ("test_checkRemoteURL", test_checkRemoteURL),
        ("test_checkLocalPath", test_checkLocalPath)
    ]

    enum Constants {
        static let simpleFile = "Simple.input"
        static let package5_1 = "Package_5.1.input"
        static let targetURLTests: [(input: URL, result: URL)] = [
            (URL(staticString: "./"), URL(fileURLWithPath: "\("".bridged.absolutePathRepresentation())/Package.swift")),
            (URL(staticString: "/usr/local/tmp"), URL(fileURLWithPath: "/usr/local/tmp/Package.swift"))
        ]

        static let localPathTests: [(input: String, result: Bool)] = [
            ("path/to/some.xcframework", true),
            ("path/to/some.zip", false),
            ("http://path/to/some.xcframework", false),
            ("https://path/to/some.xcframework", false),
            ("ftp://path/to/some.xcframework", false),
            ("path/to/some.zip", false)
        ]

        static let remotePathTests: [(input: URL, result: Bool)] = [
            (URL(staticString: "path/to/some.xcframework"), false),
            (URL(staticString: "path/to/some.zip"), false),
            (URL(staticString: "http://path/to/some.zip"), true),
            (URL(staticString: "https://path/to/some.zip"), true),
            (URL(staticString: "http://path/to/some.xcframework"), false),
            (URL(staticString: "https://path/to/some.xcframework"), false),
            (URL(staticString: "ftp://path/to/some.zip"), false),
            (URL(staticString: "path/to/some.zip"), false)
        ]
    }

    func test_fileFrom() throws {
        guard let path = UtilityTests.resourcePathForFile(Constants.simpleFile), let url = URL(string: path) else {
            XCTFail("Couldn't get path for \(Constants.simpleFile)")
            return
        }

        let file = Utility.file(from: url)
        XCTAssertEqual(file?.contents, Constants.simpleFile + "\n")
    }

    func test_syntaxStructureFrom() throws {
        guard let path = UtilityTests.resourcePathForFile(Constants.package5_1),
              let url = URL(string: path),
              let file = Utility.file(from: url) else {
            XCTFail("Couldn't get path for \(Constants.package5_1)")
            return
        }

        let structure = Utility.syntaxStructure(from: file)
        XCTAssertNotNil(structure)
    }

    func test_targetURL() throws {
        for test in Constants.targetURLTests {
            let result = Utility.targetURL(outputDirectory: test.input)
            XCTAssertEqual(result, test.result, "\(test.input)")
        }
    }

    func test_checkRemoteURL() throws {
        for test in Constants.targetURLTests {
            let result = Utility.targetURL(outputDirectory: test.input)
            XCTAssertEqual(result, test.result, "\(test.input)")
        }
    }

    func test_checkLocalPath() throws {
        for test in Constants.remotePathTests {
            let result = Utility.checkRemoteURL(test.input)
            XCTAssertEqual(result, test.result, "\(test.input)")
        }
    }
}
