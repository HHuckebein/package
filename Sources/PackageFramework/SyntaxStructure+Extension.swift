import Foundation
import SourceKittenFramework

extension SyntaxStructure {
    public func packageName(from file: File) -> String? {
        guard let structure = packageNameStructure(from: file) else { return nil }
        guard let offset = structure.bodyoffset, let length = structure.bodylength else { return nil }
        // offsets include quotation marks
        let start = offset + 1
        let end = start + length - 2
        guard let range = file.contents.range(from: start..<end) else { return nil }
        return String(file.contents[range])
    }

    public func targetInformation(for target: Target, name: String, file: File) -> (range: Range<String.Index>, structure: SyntaxStructure)? {
        // find the .targets section and the elements arrary
        // containing offset and length information of all target sections within
        guard let targetsStructure = targetsStructure(from: file)?.substructure?.first,
              let targetSubStructures = targetsStructure.substructure else { return nil }

        // iterate over a all elements to get the targets identifier
        //
        var targetStructure: SyntaxStructure? = nil
        var targetStructureRange: Range<String.Index>? = nil
        for element in targetSubStructures {
            // find the element expression identifier
            guard let identifier = element.name,
                  let nameAttribute = element.substructure?.first,
                  let targetName = nameAttribute.string(in: file, offset: nameAttribute.bodyoffset, length: nameAttribute.bodylength)  else { continue }
            // check correct target, target name
            // copy substructure and target section range for update operation
            if identifier == target.rawValue, targetName == name, let range = element.range(in: file, offset: element.offset, length: element.length) {
                targetStructure = element
                targetStructureRange = range
                break
            }
        }
        guard let structure = targetStructure, let range = targetStructureRange else { return nil }
        return (range, structure)
    }

    // MARK: - Structure Access
    func packageNameStructure(from file: File) -> SyntaxStructure? {
        let results = filter(keyName: "name", keyKind: .expArgument)
        return results.count > 0 ? results.first : nil
    }

    func targetsStructure(from file: File) -> SyntaxStructure? {
        let results = filter(keyName: "targets", keyKind: .expArgument, containsSubSubstructures: true)
        return results.count == 1 ? results.last : nil
    }

    // MARK: - Remote Binary Target

    public func updateTarget(url: URL, checksum: String, range: Range<String.Index>, in file: File) -> String? {
        var binarySection = String(file.contents[range])

        guard let urlElement = substructure?[Constants.BinaryTarget.Remote.urlIdx],
              let urlReplacement = urlElement.string(in: file, offset: urlElement.bodyoffset, length: urlElement.bodylength) else { return nil }

        guard let checkSumElement = substructure?[Constants.BinaryTarget.Remote.checksumIdx],
              let checkSumReplacment = checkSumElement.string(in: file, offset: checkSumElement.bodyoffset, length: checkSumElement.bodylength) else { return nil }

        binarySection = binarySection.replacingOccurrences(of: urlReplacement, with: url.absoluteString)
        binarySection = binarySection.replacingOccurrences(of: checkSumReplacment, with: checksum)

        return file.contents.replacingCharacters(in: range, with: binarySection)
    }

    public func appendTarget(name: String, url: URL, checksum: String, in file: File) -> String? {
        guard let insertIdx = targetsStructure(from: file)?.substructure?.first?.elements?.last?.insertionIndex(in: file) else { return nil }
        let string = String(format: Constants.BinaryTarget.Remote.binaryTargetFormat, name, url.absoluteString, checksum)
        var contents = file.contents
        contents.insert(contentsOf: string, at: insertIdx)

        return contents
    }

    // MARK: - Local Binary Target

    public func updateTarget(path: String, range: Range<String.Index>, in file: File, verbose: Bool) -> String? {
        var binarySection = String(file.contents[range])

        guard let pathElement = substructure?[Constants.BinaryTarget.Local.pathIdx],
              let pathReplacement = pathElement.string(in: file, offset: pathElement.bodyoffset, length: pathElement.bodylength) else {
            if verbose { Log.error(destination: .package,
                                   message: "Write BinaryTarget(update): couldn't find path element at index \(Constants.BinaryTarget.Local.pathIdx)") }
            return nil
        }

        binarySection = binarySection.replacingOccurrences(of: pathReplacement, with: path)

        return file.contents.replacingCharacters(in: range, with: binarySection)
    }

    public func appendTarget(name: String, path: String, in file: File, verbose: Bool) -> String? {
        guard let insertIdx = targetsStructure(from: file)?.substructure?.first?.elements?.last?.insertionIndex(in: file) else {
            if verbose { Log.error(destination: .package,
                                   message: "Write BinaryTarget(append): couldn't find insertion index") }
            return nil
        }
        let string = String(format: Constants.BinaryTarget.Local.binaryTargetFormat, name, path)
        var contents = file.contents
        contents.insert(contentsOf: string, at: insertIdx)

        return contents
    }

    // MARK: - General

    func filter(keyName: String, keyKind: Kind, containsSubSubstructures: Bool = false) -> [SyntaxStructure] {
        let result = filter { $0.name == keyName && $0.kind == keyKind }
        if containsSubSubstructures == false {
            return result.filter({ $0.substructure?.first?.substructure == nil })
        } else {
            return result.filter({ $0.substructure?.first?.substructure?.isEmpty == false })
        }
    }

    func filter(_ isIncluded: (SyntaxStructure) -> Bool) -> [SyntaxStructure] {
        var results: [SyntaxStructure] = []
        if let subs = substructure {
            for sub in subs {
                let result = sub.filter(isIncluded)
                results.append(contentsOf: result)
            }
        }
        if isIncluded(self) { results.append(self) }
        return results
    }
}

// MARK: - Extension

private extension SyntaxStructure {
    func string(in file: File, offset: Int?, length: Int?) -> String? {
        guard let range = range(in: file, offset: offset, length: length) else { return nil }
        return String(file.contents[range])
    }

    func range(in file: File, offset: Int?, length: Int?) -> Range<String.Index>? {
        guard let offset = offset, let length = length else { return nil }
        let start = offset + 1
        let end = start + length - 2
        guard let range = file.contents.range(from: start..<end) else { return nil }
        return range
    }

    func insertionIndex(in file: File) -> String.Index? {
        let string = file.contents
        guard let offset = offset, let length = length else { return nil }
        return string.index(string.startIndex, offsetBy: offset + length)
    }
}

