class Environment {

    private var enclosing: Environment?
    private(set) var values: [String: LiteralValue] = [:]

    init(enclosing: Environment? = nil) {
        self.enclosing = enclosing
    }

    func define(name: String, value: LiteralValue) {
        values[name] = value
    }

    func get(name: Token) throws -> LiteralValue {
        if let result = values[name.lexeme] {
            return result
        }

        else if let enclosing = enclosing {
            return try enclosing.get(name: name)
        }

        else {
            throw RuntimeError(token: name, messsage: "Undefined variable '\(name.lexeme)'.")
        }
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
