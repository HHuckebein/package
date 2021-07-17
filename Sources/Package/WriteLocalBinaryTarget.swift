import Foundation
import ArgumentParser
import PackageFramework

extension Package {
    struct WriteLocalBinaryTarget: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "add or update Package.swift with local binaryTarget information.")
        
        @Option(help: "The name of the Binary Framework Package.")
        var name: String

        @Option(help: "The url where the framework artefact can be loaded from. Must be .xcframework File.")
        var path: String

        @OptionGroup var options: Options
        
        func run() throws {
            // check path for conformance
            guard Utility.checkLocalPath(path) else { return }

            // read Package.swift
            guard let file = Utility.file(from: options.packageURL) else { return }

            // check swift-tools-version >= 5.3
            guard Utility.supportsBinaryTarget(file: file, verbose: options.verbose) else { return }

            // create syntax structure from Package.swift
            guard let structure = Utility.syntaxStructure(from: file) else { return }

            // create or update binaryTarget (.local)
            let target: BinaryTarget = .local(name: name, path: path)
            guard let content = target.content(from: file, structure: structure, verbose: options.verbose), content.isEmpty == false else {
                Log.error(destination: .package, message: "Create/Update binaryTarget operation failed")
                return
            }

            // save or print new Package.swift content
            Utility.save(content, to: options.outputDirectory,
                         debug: options.debug,
                         verbose: options.verbose)
        }
    }
}
