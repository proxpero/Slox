struct Function: Equatable {
    let name: Token
    let parameters: [Token]
    let body: [Stmt]
    let closure: Environment

    var arity: Int {
        parameters.count
    }

    func call(_ args: [LiteralValue]) throws -> LiteralValue {
        let env = Environment(enclosing: closure)
        for (param, arg) in zip(parameters, args) {
            env.define(name: param.lexeme, value: arg)
        }

        do {
            for stmt in body {
                try execute(stmt, environment: env)
            }
        } catch let ret as Return {
            return ret.value
        }

        return .nil
    }
}

struct Return: Error {
    let value: LiteralValue

    init(_ value: LiteralValue) {
        self.value = value
    }
}
