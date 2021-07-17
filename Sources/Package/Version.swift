import Foundation
import ArgumentParser
import PackageFramework

extension Package {
    struct Version: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Display version.")
        func run() throws {
            Log.info(destination: .package, message: PackageFramework.Version.current.displayString)
        }
    }
}
