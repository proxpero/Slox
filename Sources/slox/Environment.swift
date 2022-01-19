class Environment: Equatable {
    static func == (lhs: Environment, rhs: Environment) -> Bool {
        lhs === rhs
    }

    private var enclosing: Environment?
    private(set) var values: [String: LiteralValue] = [:]

    init(enclosing: Environment? = nil) {
        self.enclosing = enclosing
    }

    func define(name: String, value: LiteralValue) {
        values[name] = value
    }

    func get(_ key: String) -> LiteralValue? {
        if let result = values[key] { return result }
        if let enclosing = enclosing { return enclosing.get(key) }
        return nil
    }

    func get(name: Token) throws -> LiteralValue {
        guard let result = get(name.lexeme) else {
            throw RuntimeError(token: name, messsage: "Undefined variable '\(name.lexeme)'.")
        }
        return result
    }

    func assign(name: Token, value: LiteralValue) throws {
        if values[name.lexeme] != nil {
            values[name.lexeme] = value
        }

        else if let enclosing = enclosing {
            try enclosing.assign(name: name, value: value)
        }

        else {
            throw RuntimeError(token: name, messsage: "Undefined variable '\(name.lexeme)'.")
        }
    }

    static let global = Environment()
}
