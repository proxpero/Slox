import Foundation

public struct Slox {

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
        let source = String(decoding: daa, as: UTF8.self)
        run(source)
    }

    private static func runPrompt() throws {
        while true {
            print("> ", terminator: "")
            guard let line = readLine() else { return }
            run(line)
        }
    }

    private static func run(_ source: String) {
        print(source)
    }
}
