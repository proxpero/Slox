import Foundation
class Parser {
    let tokens: [Token]
    private var current = 0

    init(tokens: [Token]) {
        self.tokens = tokens
    }

    func parse() throws -> [Stmt] {
        var statements: [Stmt] = []
        while !isAtEnd {
            if let statement = try declaration() {
                statements.append(statement)
            }
        }
        return statements
    }
}

private extension Parser {
    /*
     program        → declaration* EOF ;
     declaration    → funDecl | varDecl | statement
     funDecl        → "fun" function
     function       → IDENTIFIER "(" parameters? ")" block
     parameters     → IDENTIFIER ( "," IDENTIFIER )*
     varDecl        → "var" IDENTIFIER ( "=" expression )? ";"
     statement      → exprStmt | ifStmt | printStmt | returnStmt | whileStmt | block
     exprStmt       → expression ";"
     ifStmt         → "if" expression "{" statement "}" ( "else" "{" statement "}" )?
     printStmt      → "print" expression ";"
     returnStmt     → "return" expression? ";"
     whileStmt      → "while" expression "{" statement "}"
     block          → "{" declaration* "}"
     expression     → assignment
     assignment     → IDENTIFIER "=" assignment | logic_or
     logic_or       → logic_and ( "or" logic_and )*
     logic_and      → equality ( "and" equality )*
     equality       → comparison ( ( "!=" | "==" ) comparison )*
     comparison     → term ( ( ">" | ">=" | "<" | "<=" ) term )*
     term           → factor ( ( "-" | "+" ) factor )*
     factor         → unary ( ( "/" | "*" ) unary )*
     unary          → ( "!" | "-" ) unary | call
     call           → primary ( "(" arguments? ")" )* ;
     primary        → NUMBER | STRING | "true" | "false" | "nil" | "(" expression ")" | IDENTIFIER ;
     */

    func declaration() throws -> Stmt? {
        do {
            if matches(.fun) { return try function(kind: "function") }
            if matches(.var) { return try varDeclaration() }
            return try statement()
        } catch is ParseError {
            synchronize()
            return nil
        }
    }

    private func synchronize() {
        advance()
        while !isAtEnd {
            if previous.type == .semicolon { return }

            switch peek.type {
            case .class,
                 .for,
                 .fun,
                 .if,
                 .print,
                 .return,
                 .var,
                 .while: return
            default: advance()
            }
        }
    }

    func function(kind: String) throws -> Stmt {
        let name = try consumeIdentifier()
        try consume(.leftParen, "Expected '(' after \(kind)")
        var parameters: [Token] = []
        if !check(.rightParen) {
            repeat {
                parameters.append(try consumeIdentifier(kind: kind))
            } while matches(.comma)
        }
        try consume(.rightParen, "Expected ')' after parameters")
        try consume(.leftBrace, "Expected '{'")
        let body = try block()
        return .function(name: name, parameters: parameters, body: body)
    }

    func varDeclaration() throws -> Stmt {
        let name = try consumeIdentifier()
        guard matches(.equal) else {
            throw ParseError()
        }
        let initializer = try expression()
        try consumeSemicolon()
        return .variable(name.lexeme, initializer)
    }

    func statement() throws -> Stmt {
        if matches(.print) {
            return try printStatement()
        }

        if matches(.if) {
            return try ifStatement()
        }

        if matches(.return) {
            return try returnStatement()
        }

        if matches(.while) {
            return try whileStatement()
        }

        if matches(.leftBrace) {
            return .block(try block())
        }

        return try expressionStatement()
    }

    func printStatement() throws -> Stmt {
        let value = try expression()
        try consumeSemicolon()
        return .print(value)
    }

    func ifStatement() throws -> Stmt {
        let condition = try expression()
        let thenBranch = try statement()
        var elseBranch: Stmt?
        if matches(.else) {
            elseBranch = try statement()
        }
        return .if(conditon: condition, then: thenBranch, else: elseBranch)
    }

    func returnStatement() throws -> Stmt {
        let value = try expression()
        try consume(.semicolon, "Expected ';' after return value.")
        return .return(value)
    }

    func whileStatement() throws -> Stmt {
        let condition = try expression()
        let body = try statement()
        return .while(condition: condition, body: body)
    }

    func block() throws -> [Stmt] {
        var results: [Stmt] = []
        while !check(.rightBrace), !isAtEnd {
            if let stmt = try declaration() {
                results.append(stmt)
            }
        }
        try consume(.rightBrace, "Expected '}' after block.")
        return results
    }

    func expressionStatement() throws -> Stmt {
        let expr = try expression()
        try consumeSemicolon()
        return .expr(expr)
    }

    func expression() throws -> Expr {
        try assignment()
    }

    func assignment() throws -> Expr {
        let expr = try or()
        if matches(.equal) {
            let equals = previous
            let value = try assignment()
            guard case .variable(let name) = expr else {
                throw error(equals, "Invalid assignment target.")
            }
            return .assign(name: name, value: value)
        }
        return expr
    }

    func or() throws -> Expr {
        var expr = try and()
        while matches(.or) {
            let op = previous
            let rhs = try and()
            expr = .logical(lhs: expr, op: op, rhs: rhs)
        }
        return expr
    }

    func and() throws -> Expr {
        var expr = try equality()
        while matches(.and) {
            let op = previous
            let rhs = try equality()
            expr = .logical(lhs: expr, op: op, rhs: rhs)
        }
        return expr
    }

    func equality() throws -> Expr {
        var expr = try comparison()
        while matches(.bangEqual, .equalEqual) {
            let op = previous
            let right = try comparison()
            expr = .binary(lhs: expr, op: op, rhs: right)
        }
        return expr
    }

    func comparison() throws -> Expr {
        var expr = try term()
        while matches(.greater, .greaterEqual, .less, .lessEqual) {
            let op = previous
            let right = try term()
            expr = .binary(lhs: expr, op: op, rhs: right)
        }
        return expr
    }

    func term() throws -> Expr {
        var expr = try factor()
        while matches(.minus, .plus) {
            let op = previous
            let right = try factor()
            expr = .binary(lhs: expr, op: op, rhs: right)
        }
        return expr
    }

    func factor() throws -> Expr {
        var expr = try unary()
        while matches(.slash, .star) {
            let op = previous
            let right = try unary()
            expr = .binary(lhs: expr, op: op, rhs: right)
        }
        return expr
    }

    func unary() throws -> Expr {
        if matches(.bang, .minus) {
            let op = previous
            let right = try unary()
            return .unary(op: op, rhs: right)
        }
        return try call()
    }

    func call() throws -> Expr {

        func finish(callee: Expr) throws -> Expr {
            var arguments: [Expr] = []
            if !check(.rightParen) {
                repeat {
                    arguments.append(try expression())
                } while matches(.comma)
            }
            let paren = try consume(.rightParen, "Expected ')' after arguments.")
            return .call(callee: callee, paren: paren, arguments: arguments)
        }

        var expr = try primary()
        while true {
            guard matches(.leftParen) else {
                break
            }
            expr = try finish(callee: expr)
        }
        return expr
    }

    func primary() throws -> Expr {
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
            try consume(.rightParen, "Expected ')' after expression.")
            return .grouping(expr: expr)
        }

        if matchesIdentifier() {
            return .variable(name: previous)
        }

        if matches(.var) {
            return .variable(name: previous)
        }

        throw ParseError()
    }
}

private extension Parser {
    struct ParseError: Error {}

    var isAtEnd: Bool {
        peek.type == .eof
    }

    var peek: Token {
        tokens[current]
    }

    var previous: Token {
        tokens[current - 1]
    }

    func matchesIdentifier() -> Bool {
        guard !isAtEnd, peek.type.isIdentifier else { return false }
        advance()
        return true
    }

    func matches(_ types: TokenType...) -> Bool {
        for type in types {
            if check(type) {
                advance()
                return true
            }
        }
        return false
    }

    @discardableResult
    func consumeIdentifier(kind: String? = nil) throws -> Token {
        guard !isAtEnd, case .identifier = peek.type else {
            throw error(peek, "Expected \(kind != nil ? kind! : "") identifier.")
        }
        let token = peek
        advance()
        return token
    }

    @discardableResult
    func consumeSemicolon() throws -> Token {
        if check(.semicolon) { return advance() }
        throw error(peek, "Expected semicolon after value.")
    }

    @discardableResult
    func consume(_ type: TokenType, _ message: String) throws -> Token {
        if check(type) { return advance() }
        throw error(peek, message)
    }

    func check(_ tokenType: TokenType) -> Bool {
        if isAtEnd { return false }
        return peek.type == tokenType
    }

    @discardableResult
    func advance() -> Token {
        if !isAtEnd { current += 1 }
        return previous
    }

    func error(_ token: Token, _ message: String) -> Error {
        Slox.error(token, message)
        return ParseError()
    }
}
