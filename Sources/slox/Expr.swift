enum LiteralValue: Equatable {
    case bool(Bool)
    case number(Double)
    case string(String)
    case `nil`
}

indirect enum Expr: Equatable {
    case binary(lhs: Expr, op: TokenType, rhs: Expr)
    case grouping(expr: Expr)
    case literal(value: LiteralValue)
    case unary(op: TokenType, right: Expr)
    case variable(name: TokenType)
}

extension Expr {
    static func literal(_ value: Double) -> Expr {
        .literal(value: .number(value))
    }

    static func literal(_ value: String) -> Expr {
        .literal(value: .string(value))
    }

    static func literal(_ value: Bool) -> Expr {
        .literal(value: .bool(value))
    }

    static let literalNil = Expr.literal(value: .nil)

}
