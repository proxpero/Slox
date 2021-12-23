indirect enum Expr: Equatable {
    case binary(lhs: Expr, op: Token, rhs: Expr)
    case grouping(expr: Expr)
    case literal(value: LiteralValue)
    case unary(op: Token, rhs: Expr)
}

enum LiteralValue: Equatable {
    case bool(Bool)
    case number(Double)
    case string(String)
    case `nil`
}

func eval(_ expr: Expr) throws -> LiteralValue {
    switch expr {
    case .binary(let lhs, let op, let rhs):
        let left = try eval(lhs)
        let right = try eval(rhs)
        switch op.type {
        case .minus:
            return try minus(lhs: left, rhs: right, token: op)
        case .plus:
            return try plus(lhs: left, rhs: right, token: op)
        case .star:
            return try star(lhs: left, rhs: right, token: op)
        case .slash:
            return try slash(lhs: left, rhs: right, token: op)
        case .bangEqual:
            return .bool(left != right)
        case .equalEqual:
            return .bool(left == right)
        case .greater:
            return .bool(left > right)
        case .greaterEqual:
            return .bool(left >= right)
        case .less:
            return .bool(left < right)
        case .lessEqual:
            return .bool(left <= right)
        default:
            throw RuntimeError(token: op, messsage: "Invalid Binary operands.")
        }
    case .grouping(let expr):
        return try eval(expr)
    case .literal(let value):
        return value
    case .unary(let op, let rhs):
        let right = try eval(rhs)
        switch op.type {
        case .minus:
            return try minus(rhs: right, token: op)
        case .bang:
            return try bang(rhs: right, token: op)
        default:
            throw RuntimeError(token: op, messsage: "Invalid unary operand.")
        }
    }
}

private func minus(lhs: LiteralValue, rhs: LiteralValue, token: Token) throws -> LiteralValue {
    if let l = lhs.doubleValue, let r = rhs.doubleValue {
        return .number(l - r)
    }
    throw RuntimeError(token: token, messsage: "Invalid subtrahends.")
}

private func plus(lhs: LiteralValue, rhs: LiteralValue, token: Token) throws -> LiteralValue {
    if let l = lhs.doubleValue, let r = rhs.doubleValue {
        return .number(l + r)
    }
    if let l = lhs.stringValue, let r = rhs.stringValue {
        return .string(l + r)
    }
    throw RuntimeError(token: token, messsage: "Invalid addends.")
}

private func star(lhs: LiteralValue, rhs: LiteralValue, token: Token) throws -> LiteralValue {
    if let l = lhs.doubleValue, let r = rhs.doubleValue {
        return .number(l * r)
    }
    throw RuntimeError(token: token, messsage: "Invalid factors.")
}

private func slash(lhs: LiteralValue, rhs: LiteralValue, token: Token) throws -> LiteralValue {
    if let l = lhs.doubleValue, let r = rhs.doubleValue {
        return .number(l / r)
    }
    throw RuntimeError(token: token, messsage: "Invalid dividends.")
}

private func minus(rhs: LiteralValue, token: Token) throws -> LiteralValue {
    if let r = rhs.doubleValue {
        return .number(-r)
    }
    throw RuntimeError(token: token, messsage: "Invalid value.")
}

private func bang(rhs: LiteralValue, token: Token) throws -> LiteralValue {
    if case .bool(let value) = rhs {
        return .bool(!value)
    }
    throw RuntimeError(token: token, messsage: "Invalid negation.")
}

extension LiteralValue: Comparable {
    var doubleValue: Double? {
        if case .number(let value) = self {
            return value
        }
        return nil
    }

    var stringValue: String? {
        if case .string(let value) = self {
            return value
        }
        return nil
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        if let l = lhs.doubleValue, let r = rhs.doubleValue {
            return l < r
        }
        if let l = lhs.stringValue, let r = rhs.stringValue {
            return l < r
        }
        return false
    }
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
