import Foundation

extension ComparisonResult: CustomStringConvertible {
    public var description: String {
        switch self {
        case .orderedAscending: return "orderedAscending"
        case .orderedSame: return "orderedSame"
        case .orderedDescending: return "orderedDescending"
        }
    }
}
