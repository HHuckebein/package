import Foundation
import ArgumentParser
import PackageFramework

extension Package {
    struct Version: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Display version.")
        func run() throws {
            print("Version \(PackageFramework.Version.current.displayString)")
        }
    }
}
