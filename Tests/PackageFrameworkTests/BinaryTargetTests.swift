import XCTest
import SourceKittenFramework
@testable import PackageFramework
import class Foundation.Bundle

final class UpdateTests: XCTestCase {
    enum Constants {
        enum FileName {
            static let package5_1 = "Package_5.1.input"

            static let package5_3 = "Package_5.3.input"
            static let package5_3_remoteBinaryTarget = "Package_5.3_remoteBinaryTarget.input"
            static let package5_3_localBinaryTarget = "Package_5.3_localBinaryTarget.input"

            static let package5_4 = "Package_5.4.input"
            static let package5_4_remoteBinaryTarget = "Package_5.4_remoteBinaryTarget.input"
            static let package5_4_localBinaryTarget = "Package_5.4_localBinaryTarget.input"
        }

        static let versionTests: [(filename: String, result: ComparisonResult)] = [
            (FileName.package5_1, .orderedAscending),
            (FileName.package5_3, .orderedSame),
            (FileName.package5_4, .orderedDescending)
        ]
    }

    static var allTests = [
        ("test_swift_tools_version", test_swift_tools_version),
        ("test_package_name", test_package_name),
        ("test_binaryTarget", test_binaryTarget),
        ("test_target_Empty", test_target_Empty),
        ("test_target_Localized", test_target_Localized),
        ("test_target_LocalizedFramework", test_target_LocalizedFramework),
        ("test_testTarget_Empty", test_testTarget_Empty),
        ("test_testTarget_LocalizedTests", test_testTarget_LocalizedTests),
        ("test_remote_binaryTarget_upate", test_remote_binaryTarget_upate),
        ("test_remote_binaryTarget_insert", test_remote_binaryTarget_insert),
        ("test_local_binaryTarget_upate", test_local_binaryTarget_upate),
        ("test_local_binaryTarget_insert", test_local_binaryTarget_insert)
    ]

    // MARK: - Swift Tools Version
    func test_swift_tools_version() {
        let minVersion = Utility.Constants.minVersion

        for test in Constants.versionTests {
            // given
            guard let input = testInput(for: test.filename, verbose: false, debug: false) else {
                XCTFail("Couldn't get content of \(test.filename)"); continue
            }
            guard let version = input.file.swiftToolsVersion else {
                XCTFail("Couldn't get swift tools version"); continue
            }

            let result = version.versionCompare(minVersion)
            XCTAssertEqual(result, test.result, "\(test.filename)")
        }
    }

    // MARK: - Package Name
    func test_package_name() {
        let filename = Constants.FileName.package5_3
        // given
        guard let input = testInput(for: filename, verbose: false, debug: false) else {
            XCTFail("Couldn't get test input for \(filename)"); return
        }

        // when
        guard let packageName = input.structure.packageName(from: input.file) else {
            XCTFail("Couldn't find package name"); return
        }

        // then
        XCTAssertEqual(packageName, "Localized")
    }

    // MARK: - Target General
    func test_binaryTarget() {
        // given
        let filename = Constants.FileName.package5_3
        let name = "Localized"
        let target: Target = .binaryTarget

        guard let input = testInput(for: filename, verbose: false, debug: false) else {
            XCTFail("Couldn't get test input for \(filename)"); return
        }

        // when
        let result = input.structure.targetInformation(for: target, name: name, file: input.file)

        // then
        XCTAssertNil(result)
    }

    func test_target_Empty() {
        // given
        let filename = Constants.FileName.package5_3
        let name = ""
        let target: Target = .target

        guard let input = testInput(for: filename, verbose: false, debug: false) else {
            XCTFail("Couldn't get test input for \(filename)"); return
        }

        // when
        let result = input.structure.targetInformation(for: target, name: name, file: input.file)

        // then
        XCTAssertNil(result)
    }

    func test_target_Localized() {
        // given
        let filename = Constants.FileName.package5_3
        let name = "Localized"
        let target: Target = .target

        guard let input = testInput(for: filename, verbose: false, debug: false) else {
            XCTFail("Couldn't get test input for \(filename)"); return
        }

        // when
        guard let result = input.structure.targetInformation(for: target, name: name, file: input.file) else {
            XCTFail("expected result to be not nil"); return
        }

        // then
        let expContent = "target(\n            name: \"Localized\",\n            dependencies: [.product(name: \"ArgumentParser\", package: \"swift-argument-parser\"),\n                           \"LocalizedFramework\"\n            ]"
        let content = String(input.file.contents[result.range])
        XCTAssertEqual(content, expContent)
    }

    func test_target_LocalizedFramework() {
        // given
        let filename = Constants.FileName.package5_3
        let name = "LocalizedFramework"
        let target: Target = .target
        guard let input = testInput(for: filename, verbose: false, debug: false) else {
            XCTFail("Couldn't get test input for \(filename)"); return
        }

        // when
        guard let result = input.structure.targetInformation(for: target, name: name, file: input.file) else {
            XCTFail("expected result to be not nil"); return
        }

        // then
        let expContent = "target(name: \"LocalizedFramework\",\n                dependencies: [.product(name: \"SourceKittenFramework\", package: \"SourceKitten\"),\n                                \"Yams\",\n                                \"Stencil\"\n                ],\n                exclude: [\"Templates\"]"
        let content = String(input.file.contents[result.range])
        XCTAssertEqual(content, expContent)
    }

    func test_testTarget_Empty() {
        // given
        let filename = Constants.FileName.package5_3
        let name = ""
        let target: Target = .testTarget
        guard let input = testInput(for: filename, verbose: false, debug: false) else {
            XCTFail("Couldn't get test input for \(filename)"); return
        }

        // when
        let result = input.structure.targetInformation(for: target, name: name, file: input.file)

        // then
        XCTAssertNil(result)
    }

    func test_testTarget_LocalizedTests() {
        // given
        let filename = Constants.FileName.package5_3
        let name = "LocalizedTests"
        let target: Target = .testTarget
        guard let input = testInput(for: filename, verbose: false, debug: false) else {
            XCTFail("Couldn't get test input for \(filename)"); return
        }

        // when
        // when
        guard let result = input.structure.targetInformation(for: target, name: name, file: input.file) else {
            XCTFail("expected result to be not nil"); return
        }

        // then
        let expContent = "testTarget(\n            name: \"LocalizedTests\",\n            dependencies: [\"LocalizedFramework\"],\n            exclude: [\"Resources\"]"
        let content = String(input.file.contents[result.range])
        XCTAssertEqual(content, expContent)
    }

    // MARK: - Remote Binary Target

    func test_remote_binaryTarget_upate() {
        // given
        let filename = Constants.FileName.package5_4
        let exepectedFilename = Constants.FileName.package5_4_remoteBinaryTarget
        let name = "NetworkingFramework"
        let url = URL(string: "https://www.apple.com/artefacts/Networking.xcframework.zip")!
        let checksum = "ec5b67ce3bacefb59e55a2a306179ecf7d53fd69f9d9f9d5d0128ce50d74b43d"

        guard let input = testInput(for: filename, verbose: false, debug: false) else {
            XCTFail("Couldn't get test input from \(filename)"); return
        }
        guard let expContent = testInput(for: exepectedFilename, verbose: false, debug: false)?.file.contents else {
            XCTFail("Couldn't get content from \(exepectedFilename)"); return
        }

        guard let targetInformation = input.structure.targetInformation(for: .binaryTarget, name: name, file: input.file) else {
            XCTFail("Couldn't get binary target \(name) syntax structure from \(filename)"); return
        }

        let targetStructure = targetInformation.structure
        let range = targetInformation.range
        // when
        let content = targetStructure.updateTarget(url: url,
                                                   checksum: checksum,
                                                   range: range,
                                                   in: input.file)

        // then
        XCTAssertEqual(content, expContent)
    }

    func test_remote_binaryTarget_insert() {
        // given
        let filename = Constants.FileName.package5_3
        let exepectedFilename = Constants.FileName.package5_3_remoteBinaryTarget

        let name = "NetworkingFramework"
        let url = URL(string: "https://www.apple.com/artefacts/Networking.xcframework.zip")!
        let checksum = "ec5b67ce3bacefb59e55a2a306179ecf7d53fd69f9d9f9d5d0128ce50d74b43d"

        guard let input = testInput(for: filename, verbose: false, debug: false) else {
            XCTFail("Couldn't get test input from \(filename)"); return
        }
        guard let expContent = testInput(for: exepectedFilename, verbose: false, debug: false)?.file.contents else {
            XCTFail("Couldn't get content from \(exepectedFilename)"); return
        }

        // when
        let targetInformation = input.structure.targetInformation(for: .binaryTarget, name: name, file: input.file)
        let content = input.structure.appendTarget(name: name, url: url, checksum: checksum, in: input.file)

        // then
        XCTAssertNil(targetInformation)
        XCTAssertEqual(content, expContent)
    }

    // MARK: - Local Binary Target

    func test_local_binaryTarget_upate() {
        // given
        let filename = Constants.FileName.package5_4
        let exepectedFilename = Constants.FileName.package5_4_localBinaryTarget
        let name = "Utilities"
        let path = "./artefacts/Utilities.xcframework"

        guard let input = testInput(for: filename, verbose: false, debug: false) else {
            XCTFail("Couldn't get test input from \(filename)"); return
        }
        guard let expContent = testInput(for: exepectedFilename, verbose: false, debug: false)?.file.contents else {
            XCTFail("Couldn't get content from \(exepectedFilename)"); return
        }

        guard let targetInformation = input.structure.targetInformation(for: .binaryTarget, name: name, file: input.file) else {
            XCTFail("Couldn't get binary target \(name) syntax structure from \(filename)"); return
        }

        let targetStructure = targetInformation.structure
        let range = targetInformation.range
        // when
        let content = targetStructure.updateTarget(path: path, range: range, in: input.file, verbose: false)

        // then
        XCTAssertEqual(content, expContent)
    }

    func test_local_binaryTarget_insert() {
        // given
        let filename = Constants.FileName.package5_3
        let exepectedFilename = Constants.FileName.package5_3_localBinaryTarget

        let name = "Utilities"
        let path = "./artefacts/Utilities.xcframework"

        guard let input = testInput(for: filename, verbose: false, debug: false) else {
            XCTFail("Couldn't get test input from \(filename)"); return
        }
        guard let expContent = testInput(for: exepectedFilename, verbose: false, debug: false)?.file.contents else {
            XCTFail("Couldn't get content from \(exepectedFilename)"); return
        }

        // when
        let targetInformation = input.structure.targetInformation(for: .binaryTarget, name: name, file: input.file)
        let content = input.structure.appendTarget(name: name, path: path, in: input.file, verbose: false)

        // then
        XCTAssertNil(targetInformation)
        XCTAssertEqual(content, expContent)
    }
}

private extension UpdateTests {
    func testInput(for filename: String, verbose: Bool, debug: Bool) -> (file: File, structure: SyntaxStructure)? {
        guard let path = UpdateTests.resourcePathForFile(filename), let packageURL = URL(string: path) else {
            Log.error(destination: .framework, message: "Couldn't get content of \(filename)")
            return nil
        }

        guard let file = Utility.file(from: packageURL) else {
            Log.error(destination: .framework, message: "Couldn't get file for \(packageURL.absoluteString)")
            return nil
        }

        guard let structure = Utility.syntaxStructure(from: file) else {
            Log.error(destination: .framework, message: "Couldn't get structure for \(packageURL.absoluteString)")
            return nil
        }

        return (file, structure)
    }
}
