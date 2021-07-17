import Foundation
import SourceKittenFramework

public struct SyntaxStructure: Codable {
    enum Constants {
        enum BinaryTarget {
            enum Remote {
                static let nameIdx = 0
                static let urlIdx = 1
                static let checksumIdx = 2
                static let binaryTargetFormat = """
                ,
                        .binaryTarget(
                            name: "%@",
                            url: "%@",
                            checksum: "%@"
                        )
                """
            }
            enum Local {
                static let nameIdx = 0
                static let pathIdx = 1
                static let binaryTargetFormat = """
                ,
                        .binaryTarget(
                            name: "%@",
                            path: "%@"
                        )
                """
            }
        }
    }

    enum Kind: String, Codable {
        case commentMark = "source.lang.swift.syntaxtype.comment.mark"
        case conditionalExpr = "source.lang.swift.structure.elem.condition_expr"
        case elemExpr = "source.lang.swift.structure.elem.expr"
        case expArgument = "source.lang.swift.expr.argument"
        case expArray = "source.lang.swift.expr.array"
        case expCall = "source.lang.swift.expr.call"
        case expTuple = "source.lang.swift.expr.tuple"
        case funcFree = "source.lang.swift.decl.function.free"
        case funcStatic = "source.lang.swift.decl.function.method.static"
        case statementBrace = "source.lang.swift.stmt.brace"
        case statementIf = "source.lang.swift.stmt.if"
        case varGlobal = "source.lang.swift.decl.var.global"
        case varLocal = "source.lang.swift.decl.var.local"
        case varParameter = "source.lang.swift.decl.var.parameter"
        case varStatic = "source.lang.swift.decl.var.static"
        case `enum` = "source.lang.swift.decl.enum"
        case `struct` = "source.lang.swift.decl.struct"
        case `typealias` = "source.lang.swift.decl.typealias"
    }
    
    enum Accessibility: String, Codable {
        case `internal` = "source.lang.swift.accessibility.internal"
        case `private`  = "source.lang.swift.accessibility.private"
        case `open` = "source.lang.swift.accessibility.open"
        case `public` = "source.lang.swift.accessibility.public"
    }
    
    enum TypeName: String, Codable {
        case string = "String"
        case optionalString = "String?"
        case `int` = "Int"
        case `bool` = "Bool"
        
        var defaultValue: String {
            switch self {
            case .string: return "\"\""
            case .optionalString: return "nil"
            case .int: return "0"
            case .bool: return "false"
            }
        }
    }
    
//    let accessibility: Accessibility?
//    let attribute: String?
//    let attributes: [SyntaxStructure]?
    let bodylength: Int?
    let bodyoffset: Int?
//    let diagnosticstage: String?
    let elements: [SyntaxStructure]?
//    let inheritedTypes: [SyntaxStructure]?
    let kind: Kind?
    let length: Int?
    let name: String?
    let namelength: Int?
    let nameoffset: Int?
    let offset: Int?
//    let runtimename: String?
    let substructure: [SyntaxStructure]?
    let typename: TypeName?
    
    enum CodingKeys: String, CodingKey {
//        case accessibility = "key.accessibility"
//        case attribute = "key.attribute"
//        case attributes = "key.attributes"
        case bodylength = "key.bodylength"
        case bodyoffset = "key.bodyoffset"
//        case diagnosticstage = "key.diagnostic_stage"
        case elements = "key.elements"
//        case inheritedTypes = "key.inheritedtypes"
        case kind = "key.kind"
        case length = "key.length"
        case name = "key.name"
        case namelength = "key.namelength"
        case nameoffset = "key.nameoffset"
        case offset = "key.offset"
//        case runtimename = "key.runtime_name"
        case substructure = "key.substructure"
        case typename = "key.typename"
    }
    
    var nextIdentifier: String? {
        switch kind {
        case .enum, .varStatic, .struct: return name
        case .funcStatic: return nextIdentifier(for: self)
        default: return nil
        }
    }
}

private extension SyntaxStructure {
    func nextIdentifier(for structure: SyntaxStructure) -> String? {
        guard kind == .funcStatic else { return nil }
        guard var result = name else { return nil }
        
        guard let subStructures = structure.substructure else { return nil }
        let parameters = parameterNames(from: result)
        let lastIndex = parameters.count - 1
        for (index, parameter) in parameters.enumerated() {
            guard let defaultValue = subStructures[index].typename?.defaultValue else { continue }
            guard let range = result.range(of: "\(parameter):") else { continue }
            var replacement = " \(defaultValue)\(index != lastIndex ? ", " : "")"
            if parameter == "_" { _ = replacement.remove(at: replacement.startIndex) }
            result.insert(contentsOf: replacement, at: range.upperBound)
        }
        result = result.replacingOccurrences(of: "_:", with: "")
        return result
    }
    
    func parameterNames(from string: String) -> [String] {
        let characterSet01 = CharacterSet(charactersIn: "()")
        let characterSet02 = CharacterSet(charactersIn: ":")
        let components = string.components(separatedBy: characterSet01)
        guard components.count == 3 else { return [] }
        
        return components[1].components(separatedBy: characterSet02).filter({ $0.isEmpty == false })
    }
}

extension SyntaxStructure.Kind: CustomStringConvertible {
    var description: String {
        switch self {
        case .enum: return "enum"
        case .expCall: return "expression"
        case .funcStatic: return "static func"
        case .varStatic: return "static var"
        case .varGlobal: return "gobal var"
        case .varParameter: return "parameter"
        case .expArgument: return "argument"
        case .expArray: return "array"
        case .expTuple: return "tuple"
        case .elemExpr: return "structur expression element"
        case .commentMark: return "mark"
        case .conditionalExpr: return "conditionalExpression"
        case .statementIf: return "ifStatement"
        case .statementBrace: return "brace"
        case .varLocal: return "local var"
        case .typealias: return "typealias"
        case .struct: return "struct"
        case .funcFree: return "free function"
        }
    }
}

extension SyntaxStructure.Accessibility: CustomStringConvertible {
    var description: String {
        switch self {
        case .internal: return "internal"
        case .private: return "private"
        case .open: return "open"
        case .public: return "public"
        }
    }
}
