import Foundation

public enum Slox {
    private static var hadError = false

    public static func main(_ args: [String]) throws {
        if args.isEmpty {
            try runPrompt()
        } else if let path = args.first {
            try runFile(path)
        } else {
            print("Usage: slox [script]")
            exit(64)
        }
    }
}

extension Slox {
    private static func runFile(_ path: String) throws {
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        let source = String(decoding: data, as: UTF8.self)
        try run(source, environment: .global)
    }

    private static func runPrompt() throws {
        let environment: Environment = .global
        while true {
            print("> ", terminator: "")
            guard let line = readLine() else { return }
            try run(line, environment: environment)
        }
    }

    private static func run(_ source: String, environment: Environment) throws {
        let tokens = Scanner(source: source).scanTokens()
        do {
            let statements = try Parser(tokens: tokens).parse()
            for statement in statements {
                try execute(statement, environment: environment)
            }
        } catch let runtime as RuntimeError {
            print(runtime.messsage)
        } catch {
            print("Error")
        }
    }

    private static func report(_ line: Int, _ where: String, _ message: String) {
        fputs("[line \(line)] Error\(`where`): \(message)\n", __stderrp)
        hadError = true
    }

    static func error(_ line: Int, _ message: String) {
        report(line, "", message)
    }

    static func error(_ token: Token, _ message: String) {
        let location = token.type == .eof ? "end" : "'\(token.lexeme)'"
        report(token.line, " at \(location)", message)
    }
}
