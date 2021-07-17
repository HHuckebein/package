import XCTest
import  PackageFramework
import class Foundation.Bundle

final class PackageTargetTests: XCTestCase {
    static var allTests = [
        ("test_Package_without_parameter", test_Package_without_parameter),
        ("test_remote_binary_target_update_all_parameter_success", test_remote_binary_target_update_all_parameter_success)
    ]

    enum Constants {
        enum Parameter {
            static let remote = RemoteBinary(name: "NetworkingFramework",
                                         url: URL(string: "https://www.apple.com/artefacts/Networking.xcframework.zip")!,
                                         checksum: "ec5b67ce3bacefb59e55a2a306179ecf7d53fd69f9d9f9d5d0128ce50d74b43d",
                                         packagePath: resourcePathForFile("Package_5.4.input")!,
                                         expectedOutputURL: URL(string: resourcePathForFile("Package_5.4_remoteBinaryTarget.input")!)!)
        }
    }
    func test_Package_without_parameter() throws {
        guard #available(macOS 10.13, *) else {
            return
        }

        // given
        let packageBinary = XCTestCase.productsDirectory.appendingPathComponent("Package")

        let process = Process()
        process.executableURL = packageBinary

        let pipe = Pipe()
        process.standardOutput = pipe

        // when
        try process.run()
        process.waitUntilExit()

        // then
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)

        let expected = """
        OVERVIEW: Update Package.swift with binaryTarget Infos

        USAGE: package <subcommand>

        OPTIONS:
          -h, --help              Show help information.

        SUBCOMMANDS:
          write-remote-binary-target
                                  add or update Package.swift with remote binaryTarget
                                  information.
          write-local-binary-target
                                  add or update Package.swift with local binaryTarget
                                  information.
          version                 Display version.

          See 'package help <subcommand>' for detailed help.

        """
        XCTAssertEqual(output, expected)
    }

    func test_remote_binary_target_update_all_parameter_success() throws {
        guard #available(macOS 10.13, *) else {
            return
        }

        // given
        let packageBinary = XCTestCase.productsDirectory.appendingPathComponent("Package")

        let process = Process()
        process.executableURL = packageBinary

        let standardErrorPipe = Pipe()
        process.standardError = standardErrorPipe

        let standardOutputPipe = Pipe()
        process.standardOutput = standardOutputPipe

        process.arguments = ["write-remote-binary-target",
                             "--package-url" , Constants.Parameter.remote.packagePath,
                             "--name", Constants.Parameter.remote.name,
                             "--url",  Constants.Parameter.remote.url.absoluteString,
                             "--check-sum", Constants.Parameter.remote.checksum,
                             "--debug"]

        // when
        try process.run()
        process.waitUntilExit()

        // then
        // Check Error output
        let standardErrorData = standardErrorPipe.fileHandleForReading.readDataToEndOfFile()
        if let errorString = String(data: standardErrorData, encoding: .utf8) {
            XCTAssertTrue(errorString.isEmpty); return
        }

        let standardOutputData = standardOutputPipe.fileHandleForReading.readDataToEndOfFile()
        if let content = String(data: standardOutputData, encoding: .utf8) {
            XCTAssertEqual(content, Constants.Parameter.remote.expectedOutput)
        } else {
            XCTFail("Writing remote binary target failed. Missing output")
        }
    }
}

class RemoteBinary {
    let name: String
    let url: URL
    let checksum: String
    let packagePath: String

    let expectedOutputURL: URL
    lazy var expectedOutput: String? = {
        Utility.file(from: self.expectedOutputURL)!.contents + "\n"
    }()

    init(name: String, url: URL, checksum: String, packagePath: String, expectedOutputURL: URL) {
        self.name = name
        self.url = url
        self.checksum = checksum
        self.packagePath = packagePath
        self.expectedOutputURL = expectedOutputURL
    }
}
