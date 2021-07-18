import Foundation
import ArgumentParser
import PackageFramework

extension Package {
    struct WriteRemoteBinaryTarget: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "add or update Package.swift with remote binaryTarget information.")
        
        @Option(help: "The name of the Binary Framework Package.")
        var name: String

        @Option(help: "The url where the framework artefact can be loaded from. PathExtension must be .zip.")
        var url: URL

        @Option(help: "The checksum of the XCFramework. (swift package compute-checksum YourFramework.xcframework)")
        var checkSum: String

        @OptionGroup var options: Options
        
        func run() throws {
            // check url for conformance
            guard Utility.checkRemoteURL(url) else { return }

            // read Package.swift
            guard let file = Utility.file(from: options.packageURL) else { return }

            // check swift-tools-version >= 5.3
            guard Utility.supportsBinaryTarget(file: file, verbose: options.verbose) else { return }

            // create syntax structure from Package.swift
            guard let structure = Utility.syntaxStructure(from: file) else { return }

            // create or update binaryTarget (.remote)
            let target: BinaryTarget = .remote(name: name, url: url, checkSum: checkSum)
            guard let content = target.content(from: file, structure: structure, verbose: options.verbose), content.isEmpty == false else {
                print("Package Error: Create/Update binaryTarget operation failed")
                return
            }

            // save or print new Package.swift content
            Utility.save(content, to: options.outputDirectory,
                         debug: options.debug,
                         verbose: options.verbose)
        }
    }
}
