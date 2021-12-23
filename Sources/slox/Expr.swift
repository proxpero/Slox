indirect enum Expr: Equatable {
    case binary(lhs: Expr, op: TokenType, rhs: Expr)
    case grouping(expr: Expr)
    case literal(value: LiteralValue)
    case unary(op: TokenType, rhs: Expr)
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
        switch op {
        case .minus:
            return try left - right
        case .plus:
            return try left + right
        case .star:
            return try left * right
        case .slash:
            return try left / right
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
            throw RuntimeError()
        }
    case .grouping(let expr):
        return try eval(expr)
    case .literal(let value):
        return value
    case .unary(let op, let rhs):
        let right = try eval(rhs)
        switch op {
        case .minus:
            return try -right
        case .bang:
            return try !right
        default:
            throw RuntimeError()
        }
    }
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

    static func - (lhs: Self, rhs: Self) throws -> LiteralValue {
        if let l = lhs.doubleValue, let r = rhs.doubleValue {
            return .number(l - r)
        }
        throw RuntimeError()
    }

    static func + (lhs: Self, rhs: Self) throws -> LiteralValue {
        if let l = lhs.doubleValue, let r = rhs.doubleValue {
            return .number(l + r)
        }
        if let l = lhs.stringValue, let r = rhs.stringValue {
            return .string(l + r)
        }
        throw RuntimeError()
    }

    static func * (lhs: Self, rhs: Self) throws -> LiteralValue {
        if let l = lhs.doubleValue, let r = rhs.doubleValue {
            return .number(l * r)
        }
        throw RuntimeError()
    }

    static func / (lhs: Self, rhs: Self) throws -> LiteralValue {
        if let l = lhs.doubleValue, let r = rhs.doubleValue {
            return .number(l / r)
        }
        throw RuntimeError()
    }

    static prefix func - (rhs: Self) throws -> LiteralValue {
        if let r = rhs.doubleValue {
            return .number(-r)
        }
        throw RuntimeError()
    }

    static prefix func ! (rhs: Self) throws -> LiteralValue {
        if case bool(let value) = rhs {
            return .bool(!value)
        }
        throw RuntimeError()
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
