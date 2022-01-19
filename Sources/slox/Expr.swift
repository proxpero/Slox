indirect enum Expr: Equatable {
    case assign(name: Token, value: Expr)
    case binary(lhs: Expr, op: Token, rhs: Expr)
    case call(callee: Expr, paren: Token, arguments: [Expr])
    case grouping(expr: Expr)
    case literal(value: LiteralValue)
    case logical(lhs: Expr, op: Token, rhs: Expr)
    case unary(op: Token, rhs: Expr)
    case variable(name: Token)
}

extension Expr {
    var isVariable: Bool {
        switch self {
        case .variable:
            return true
        default:
            return false
        }
    }
}

enum LiteralValue: Equatable {
    case bool(Bool)
    case function(Function)
    case number(Double)
    case string(String)
    case `nil`
}

extension LiteralValue: CustomStringConvertible {
    var description: String {
        switch self {
        case .bool(let value):
            return String(describing: value)
        case .function:
            return "Function"
        case .number(let value):
            return String(describing: value)
        case .string(let value):
            return String(describing: value)
        case .nil:
            return "nil"
        }
    }
}
