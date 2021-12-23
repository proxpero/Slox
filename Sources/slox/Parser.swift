import Foundation
class Parser {
    let tokens: [Token]
    private var current = 0

    init(tokens: [Token]) {
        self.tokens = tokens
    }

    func parse() throws -> Expr {
        do {
            return try expression()
        } catch {
            throw ParseError()
        }
    }
}

extension Parser {
    /*
     expression     → equality ;
     equality       → comparison ( ( "!=" | "==" ) comparison )* ;
     comparison     → term ( ( ">" | ">=" | "<" | "<=" ) term )* ;
     term           → factor ( ( "-" | "+" ) factor )* ;
     factor         → unary ( ( "/" | "*" ) unary )* ;
     unary          → ( "!" | "-" ) unary
                    | primary ;
     primary        → NUMBER | STRING | "true" | "false" | "nil"
                    | "(" expression ")" ;
     */

    private func expression() throws -> Expr {
        try equality()
    }

    private func equality() throws -> Expr {
        var expr = try comparison()
        while matches(.bangEqual, .equalEqual) {
            let op = previous
            let right = try comparison()
            expr = .binary(lhs: expr, op: op, rhs: right)
        }
        return expr
    }

    private func comparison() throws -> Expr {
        var expr = try term()
        while matches(.greater, .greaterEqual, .less, .lessEqual) {
            let op = previous
            let right = try term()
            expr = .binary(lhs: expr, op: op, rhs: right)
        }
        return expr
    }

    private func term() throws -> Expr {
        var expr = try factor()
        while matches(.minus, .plus) {
            let op = previous
            let right = try factor()
            expr = .binary(lhs: expr, op: op, rhs: right)
        }
        return expr
    }

    private func factor() throws -> Expr {
        var expr = try unary()
        while matches(.slash, .star) {
            let op = previous
            let right = try unary()
            expr = .binary(lhs: expr, op: op, rhs: right)
        }
        return expr
    }

    private func unary() throws -> Expr {
        if matches(.bang, .minus) {
            let op = previous
            let right = try unary()
            return .unary(op: op, rhs: right)
        }
        return try primary()
    }

    private func primary() throws -> Expr {

        if matches(.false) {
            return .literal(value: .bool(false))
        }

        if matches(.true) {
            return .literal(value: .bool(true))
        }

        if matches(.nil) {
            return .literal(value: .nil)
        }

        if case .number(let value) = peek.type {
            advance()
            return .literal(value: .number(value))
        }

        if case .string(let value) = peek.type {
            advance()
            return .literal(value: .string(value))
        }

        if matches(.leftParen) {
            let expr = try expression()
            try consume(.rightParen, "Expect ')' after expression.")
            return .grouping(expr: expr)
        }

        throw ParseError()
    }
}

extension Parser {
    private struct ParseError: Error {}

    private var isAtEnd: Bool {
        peek.type == .eof
    }

    private var peek: Token {
        tokens[current]
    }

    private var previous: Token {
        tokens[current - 1]
    }

    private func matches(_ types: TokenType...) -> Bool {
        for type in types {
            if check(type) {
                advance()
                return true
            }
        }
        return false
    }

    @discardableResult
    private func consume(_ type: TokenType, _ message: String) throws -> Token {
        if check(type) { return advance() }

        throw error(peek, message)
    }

    private func check(_ tokenType: TokenType) -> Bool {
        if isAtEnd { return false }
        return peek.type == tokenType
    }

    @discardableResult
    private func advance() -> Token {
        if !isAtEnd { current += 1 }
        return previous
    }

    private func error(_ token: Token, _ message: String) -> Error {
        Slox.error(token, message)
        return ParseError()
    }
}
