import Foundation
import ArgumentParser

struct Package: ParsableCommand {
    public static let configuration = CommandConfiguration(abstract: "Update Package.swift with binaryTarget Infos",
                                                           subcommands: [WriteRemoteBinaryTarget.self,
                                                                         WriteLocalBinaryTarget.self,
                                                                         Version.self])
}

Package.main()
