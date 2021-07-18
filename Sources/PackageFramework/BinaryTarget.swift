import Foundation
import SourceKittenFramework

public enum BinaryTarget {
    case local(name: String, path: String)
    case remote(name: String, url: URL, checkSum: String)


    public func content(from file: File, structure: SyntaxStructure, verbose: Bool) -> String? {
        if let targetInfo = structure.targetInformation(for: .binaryTarget, name: name, file: file) {
            if verbose { print("Package Error: Write BinaryTarget: update") }
            return update(from: file, targetInfo: targetInfo, verbose: verbose)
        } else {
            if verbose { print("Package Error: Write BinaryTarget: append") }
            return append(from: file, structure: structure, verbose: verbose)
        }
    }
}

private extension BinaryTarget {
    var name: String {
        switch self {
        case .local(name: let name, path: _): return name
        case .remote(name: let name, url: _, checkSum: _): return name
        }
    }

    func update(from file: File, targetInfo: (range: Range<String.Index>, structure: SyntaxStructure), verbose: Bool) -> String? {
        switch self {
        case .local(name: _, path: let path):
            return targetInfo.structure.updateTarget(path: path, range: targetInfo.range, in: file, verbose: verbose)

        case .remote(name: _, url: let url, checkSum: let checkSum):
            return targetInfo.structure.updateTarget(url: url, checksum: checkSum, range: targetInfo.range, in: file)
        }
    }

    func append(from file: File, structure: SyntaxStructure, verbose: Bool) -> String? {
        switch self {
        case .local(name: let name, path: let path):
            return structure.appendTarget(name: name, path: path, in: file, verbose: verbose)

        case .remote(name: let name, url: let url, checkSum: let checkSum):
            return structure.appendTarget(name: name, url: url, checksum: checkSum, in: file)
        }
    }
}
