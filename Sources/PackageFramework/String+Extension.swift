import Foundation

public extension String {
    /// Extracts a substring between a given begin(`from`)/end(`to`) delimiter.
    /// Delimiters are not included.
    /// e.g. "scheme://host#access_token=eyJhbGciOiJSUzI1N...BQ&token_type=bearer&session_state=602dad3c-0160-43d0-b3c5-a7e465099ba7&expires_in=2592000&not-before-policy=0"
    /// Special care is taken if the begin delimiter is found but the substring reaches the end of the string.
    ///
    /// - Parameters:
    ///   - from: Begin delimiter.
    ///   - to: End delimiter. Searches also to the very end of the string thus ignoring `to` if from to fails.
    /// - Returns: The substring if it exits.
    func extract(from: String, to: String) -> String? {
        var nFrom = from
        var nTo = to

        if from.isSpecialCharacter { nFrom = "\\" + nFrom }
        if to.isSpecialCharacter { nTo = "\\" + nTo }

        let pattern = String(format:"(?<=%@).*?(?=%@)", nFrom, nTo)
        let pattern1 = String(format:"(?<=%@).*", nFrom)
        var range: Range<String.Index>?
        if let regex = try? NSRegularExpression(pattern: pattern),
            let match = regex.firstMatch(in: self, range: NSRange(self.startIndex..., in: self)) {
            range = Range(match.range, in: self)
        } else if let regex = try? NSRegularExpression(pattern: pattern1),
            let match = regex.firstMatch(in: self, range: NSRange(self.startIndex..., in: self)) {
            range = Range(match.range, in: self)
        }

        if let range = range {
            return String(self[range])
        } else {
            return nil
        }
    }

    private var isSpecialCharacter: Bool {
        count == 1 && (contains(".") || contains("*") || contains("\\"))
    }

    func versionCompare(_ otherVersion: String) -> ComparisonResult {
        compare(otherVersion, options: .numeric)
    }

    var bridged: NSString { self as NSString  }

    func range(from range: Range<Int>) -> Range<String.Index>? {
        guard
            let from = index(startIndex, offsetBy: range.lowerBound, limitedBy: endIndex),
            let to = index(startIndex, offsetBy: range.upperBound, limitedBy: endIndex)
        else {
            Log.error(destination: .framework, message: "Getting String.Index out of \(range) failed")
            return nil
        }
        return from ..< to
    }

    func firstIndex(of: String, at: String.Index) -> String.Index? {
        self[at...].range(of: of)?.lowerBound
    }
}

