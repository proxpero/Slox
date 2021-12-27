@testable import Slox
import XCTest

final class StatementTests: XCTestCase {

    func statements(_ source: String) throws -> [Stmt] {
        let tokens = Scanner(source: source).scanTokens()
        let stmts = try Parser(tokens: tokens).parse()
        return stmts
    }

    func testVariableDeclaration() throws {
        let environment = Environment()
        let tokens = Scanner(source: "var x = 12;").scanTokens()
        let stmts = try Parser(tokens: tokens).parse()
        try execute(stmts[0], environment: environment)
        let result = try environment.get(name: tokens[1])
        XCTAssertEqual(result, .number(12))
    }

    func testVariableDeclarationAndEvaluation() throws {
        let environment = Environment()
        let tokens = Scanner(source: "var x = 12 + 8;").scanTokens()
        let stmts = try Parser(tokens: tokens).parse()
        try execute(stmts[0], environment: environment)
        let result = try environment.get(name: tokens[1])
        XCTAssertEqual(result, .number(20))
    }

    func testVariableDeclarationAndRetrieval() throws {
        let environment = Environment()
        let stmts = try statements("""
        var x = 12;
        var y = x + 8;
        """)
        try execute(stmts, environment: environment)
        let result = try environment.get(name: Token(type: .identifier("y"), line: 2))
        XCTAssertEqual(result, .number(20))
    }

    func testVariableRedefinition() throws {
        let environment = Environment()
        var stmts: [Stmt]
        var result: LiteralValue

        stmts = try statements("var x = 12;")
        try execute(stmts, environment: environment)
        result = try environment.get(name: Token(type: .identifier("x"), line: 2))
        XCTAssertEqual(result, .number(12))

        stmts = try statements("x = 20;")
        try execute(stmts, environment: environment)
        result = try environment.get(name: Token(type: .identifier("x"), line: 2))
        XCTAssertEqual(result, .number(20))
    }

    func testScoping() throws {
        let source = """
        var a = "global a";
        var b = "global b";
        var c = "global c";
        {
          var a = "outer a";
          var b = "outer b";
          {
            var a = "inner a";
            print a;
            print b;
            print c;
          }
          print a;
          print b;
          print c;
        }
        print a;
        print b;
        print c;
        """
        let env = Environment()
        let stmts = try statements(source)
        try stmts.forEach({ try execute($0, environment: env) })
    }

    func testIncrementing() throws {
        let env = Environment()
        let stmts = try statements("""
        var y = 1;
        y = y + 5;
        """)
        try execute(stmts, environment: env)
        XCTAssertEqual(env.values["y"]?.doubleValue, 6)
    }

    func testIf() throws {
        let env = Environment()
        let source = """
        var y = 1;
        if true {
            y = 2;
        }
        """
        var result: LiteralValue?
        let stmts = try statements(source)

        try execute(stmts[0], environment: env)
        result = env.values["y"]
        XCTAssertEqual(result?.doubleValue, 1)

        try execute(stmts[1], environment: env)
        result = env.values["y"]
        XCTAssertEqual(result?.doubleValue, 2)
    }

    func testEvaluatingIfCondition() throws {
        do {
            let env = Environment()
            let stmts = try statements("""
            var y = 1;
            if y > 0 {
                y = 2;
            }
            """)
            try execute(stmts, environment: env)
            XCTAssertEqual(env.values["y"]?.doubleValue, 2)
        }

        do {
            let env = Environment()
            let stmts = try statements("""
            var y = 1;
            {
                if y > 0 {
                    y = 2;
                }
            }
            """)
            try execute(stmts, environment: env)
            XCTAssertEqual(env.values["y"]?.doubleValue, 2)

        }
    }

    func testIfElse() throws {
        let env = Environment()
        let source = """
        var y = 1;
        if false {
            y = 2;
        } else {
            y = 3;
        }
        """
        var result: LiteralValue?
        let stmts = try statements(source)

        try execute(stmts[0], environment: env)
        result = env.values["y"]
        XCTAssertEqual(result?.doubleValue, 1)

        try execute(stmts[1], environment: env)
        result = env.values["y"]
        XCTAssertEqual(result?.doubleValue, 3)
    }

    func testTruthiness() throws {
        do {
            let env = Environment()
            let stmts = try statements("""
            var y = 1;
            var condition = true;
            if condition {
                y = 2;
            }
            """)
            try execute(stmts, environment: env)
            XCTAssertEqual(env.values["y"]?.doubleValue, 2)
        }

        do {
            let env = Environment()
            let stmts = try statements("""
            var y = 1;
            var condition = false;
            if condition {
                y = 2;
            }
            """)
            try execute(stmts, environment: env)
            XCTAssertEqual(env.values["y"]?.doubleValue, 1)
        }

        do {
            let env = Environment()
            let stmts = try statements("""
            var y = 1;
            var condition = 0;
            if condition {
                y = 2;
            }
            """)
            try execute(stmts, environment: env)
            XCTAssertEqual(env.values["y"]?.doubleValue, 1)
        }

        do {
            let env = Environment()
            let stmts = try statements("""
            var y = 1;
            var condition = 42;
            if condition {
                y = 2;
            }
            """)
            try execute(stmts, environment: env)
            XCTAssertEqual(env.values["y"]?.doubleValue, 2)
        }

        do {
            let env = Environment()
            let stmts = try statements("""
            var y = 1;
            var condition = "hello";
            if condition {
                y = 2;
            }
            """)
            try execute(stmts, environment: env)
            XCTAssertEqual(env.values["y"]?.doubleValue, 2)
        }

        do {
            let env = Environment()
            let stmts = try statements("""
            var y = 1;
            var condition = "";
            if condition {
                y = 2;
            }
            """)
            try execute(stmts, environment: env)
            XCTAssertEqual(env.values["y"]?.doubleValue, 1)
        }

        do {
            let env = Environment()
            let stmts = try statements("""
            var y = 1;
            var condition = nil;
            if condition {
                y = 2;
            }
            """)
            try execute(stmts, environment: env)
            XCTAssertEqual(env.values["y"]?.doubleValue, 1)
        }
    }

    func testLogicalAnd() throws {

        do {
            let env = Environment()
            let stmts = try statements("""
            var y = 1;
            if false and true {
                y = 2;
            }
            """)
            try execute(stmts, environment: env)
            XCTAssertEqual(env.values["y"]?.doubleValue, 1)
        }

        do {
            let env = Environment()
            let stmts = try statements("""
            var y = 1;
            if true and false {
                y = 2;
            }
            """)
            try execute(stmts, environment: env)
            XCTAssertEqual(env.values["y"]?.doubleValue, 1)
        }

        do {
            let env = Environment()
            let stmts = try statements("""
            var y = 1;
            if true and true {
                y = 2;
            }
            """)
            try execute(stmts, environment: env)
            XCTAssertEqual(env.values["y"]?.doubleValue, 2)
        }
    }

    func testLogicalReturnValues() throws {
        do {
            let env = Environment()
            let stmts = try statements("""
            var x = true and "hello";
            """)
            try execute(stmts, environment: env)
            XCTAssertEqual(env.values["x"]?.stringValue, "hello")
        }

        do {
            let env = Environment()
            let stmts = try statements("""
            var x = 1 or "hello";
            """)
            try execute(stmts, environment: env)
            XCTAssertEqual(env.values["x"]?.doubleValue, 1)
        }

        do {
            let env = Environment()
            let stmts = try statements("""
            var x = false or "hello";
            """)
            try execute(stmts, environment: env)
            XCTAssertEqual(env.values["x"]?.stringValue, "hello")
        }

        do {
            let env = Environment()
            let stmts = try statements("""
            var x = "hello" or 42;
            """)
            try execute(stmts, environment: env)
            XCTAssertEqual(env.values["x"]?.stringValue, "hello")
        }
    }

    func testWhileStatement() throws {
        let env = Environment()
        let stmts = try statements("""
        var i = 10;
        while i > 0 {
            i = i - 1;
        }
        """)
        try execute(stmts, environment: env)
        XCTAssertEqual(env.values["i"]?.doubleValue, 0)
    }
}
