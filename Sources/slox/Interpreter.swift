struct RuntimeError: Error {
    let token: Token
    let messsage: String
}

func eval(_ expr: Expr, environment: Environment) throws -> LiteralValue {
    switch expr {
    case .assign(let name, let value):
        let value = try eval(value, environment: environment)
        try environment.assign(name: name, value: value)
        return value

    case .binary(let lhs, let op, let rhs):
        let left = try eval(lhs, environment: environment)
        let right = try eval(rhs, environment: environment)
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
        return try eval(expr, environment: environment)
    case .literal(let value):
        return value

    case .logical(let lhs, let op, let rhs):
        let left = try eval(lhs, environment: environment)

        switch op.type {
        case .and:
            if !isTruthy(left) { return left }
        case .or:
            if isTruthy(left) { return left }
        default:
            fatalError()
        }
        return try eval(rhs, environment: environment)

    case .unary(let op, let rhs):
        let right = try eval(rhs, environment: environment)
        switch op.type {
        case .minus:
            return try minus(rhs: right, token: op)
        case .bang:
            return try bang(rhs: right, token: op)
        default:
            throw RuntimeError(token: op, messsage: "Invalid unary operand.")
        }
    case .variable(let name):
        return try environment.get(name: name)
//        throw RuntimeError(token: name, messsage: "Expected a value for \(name.lexeme)")
//        return value
    }
}

func execute(_ statements: Stmt..., environment: Environment) throws {
    try execute(statements, environment: environment)
}

func execute(_ statements: [Stmt], environment: Environment) throws {
    for statement in statements {
        switch statement {
        case .block(let stmts):
            let new = Environment(enclosing: environment)
            for stmt in stmts {
                try execute(stmt, environment: new)
            }

        case .expr(let expr):
            let v = try eval(expr, environment: environment)
            print(v)

        case .if(let conditon, let thenBranch, let elseBranch):
            if isTruthy(try eval(conditon, environment: environment)) {
                try execute(thenBranch, environment: environment)
            } else if let elseBranch = elseBranch {
                try execute(elseBranch, environment: environment)
            }

        case .print(let expr):
            let v = try eval(expr, environment: environment)
            print(v)


        case .variable(let name, let initializer):
            guard let initializer = initializer else {
                fatalError()
            }
            let value = try eval(initializer, environment: environment)
            environment.define(name: name, value: value)

        case .while(let condition, let body):
            while (isTruthy(try eval(condition, environment: environment))) {
                try execute(body, environment: environment)
            }
        }
    }
}

private func isTruthy(_ literal: LiteralValue) -> Bool {
    switch literal {
    case .bool(let bool):
        return bool
    case .number(let double):
        return double > 0
    case .string(let string):
        return !string.isEmpty
    case .nil:
        return false
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
    throw RuntimeError(token: token, messsage: "Invalid addends \(lhs), \(rhs).")
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

    var boolValue: Bool? {
        if case .bool(let value) = self {
            return value
        }
        return nil
    }

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
