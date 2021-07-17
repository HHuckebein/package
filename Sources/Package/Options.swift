import Foundation
import ArgumentParser
import PackageFramework

struct Options: ParsableArguments {
    private static let defaultPath: StaticString = "./Package.swift"

    @Option(help: "The url to the Package.swift file. Defaults to ./Package.swift")
    var packageURL: URL = URL(staticString: defaultPath)

    @Option(help: "The output directory for the generated file(s). If not specified the ")
    var outputDirectory: URL = URL(staticString: defaultPath)
    
    @Flag
    var verbose: Bool = false
    
    @Flag(help: "Prints the Swift Source Code's SyntaxStructure.")
    var debug: Bool = false
}
