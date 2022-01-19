@testable import Slox
import XCTest

final class FunctionTests: XCTestCase {
    func testFunctionClosure() throws {
        let source = """
        var y = 11;
        var z = 9;
        fun incr(x) {
            y = y + x;
        }
        incr(z);
        """
        let tokens = Scanner(source: source).scanTokens()
        let stmts = try Parser(tokens: tokens).parse()
        let env = Environment()
        try execute(stmts, environment: env)
        XCTAssertEqual(env.values["y"], .number(20))
    }

    func testFunctionReturn() throws {
        let source = """
        var x = 12;
        fun incr(x) {
            return x + 1;
        }
        var y = incr(x);
        """
        let env = Environment()
        let tokens = Scanner(source: source).scanTokens()
        let stmts = try Parser(tokens: tokens).parse()
        try execute(stmts, environment: env)
        XCTAssertEqual(env.values["y"], .number(13))
    }

    func testFunctionEnvironment() throws {
        let source = """
        var x = 12;
        fun incr() {
            x = x + 1;
        }
        incr();
        """
        let env = Environment()
        let tokens = Scanner(source: source).scanTokens()
        let stmts = try Parser(tokens: tokens).parse()
        try execute(stmts, environment: env)
        XCTAssertEqual(env.get("x"), .number(13))
    }

    func testFunctionRecursion() throws {
        let source = """
        fun fib(n) {
            if n <= 1 { return n; }
            return fib(n - 2) + fib(n - 1);
        }
        var fiftyFive = fib(10);
        """
        let env = Environment()
        let tokens = Scanner(source: source).scanTokens()
        let stmts = try Parser(tokens: tokens).parse()
        try execute(stmts, environment: env)
        XCTAssertEqual(env.values["fiftyFive"], .number(55))
    }

    func testAssigningFunctions() throws {
        let source = """
        var x = 12;
        fun incr() {
            x = x + 1;
        }
        var f = incr;
        f();
        f();
        f();
        """
        let env = Environment()
        let tokens = Scanner(source: source).scanTokens()
        let stmts = try Parser(tokens: tokens).parse()
        try execute(stmts, environment: env)
        XCTAssertEqual(env.get("x"), .number(15))
    }

    func testNestedClosures() throws {
        let source = """
        var r1 = 0;
        var r2 = 0;
        fun makeCounter() {
            var i = 0;
            fun count() {
                i = i + 1;
                return i;
            }
            return count;
        }
        var counter = makeCounter();
        r1 = counter();
        r2 = counter();
        """
        let env = Environment()
        let tokens = Scanner(source: source).scanTokens()
        let stmts = try Parser(tokens: tokens).parse()
        try execute(stmts, environment: env)
        XCTAssertEqual(env.get("r1"), .number(1))
        XCTAssertEqual(env.get("r2"), .number(2))
    }

    func testScopingMutableEnvironments() throws {
        /*
         In swift, this would emit a compile-time error saying
         that the closure (`showA`) captures `a` before it is
         declared. Basically, it knows that `a` is shadowed
         within the inner block, and binds the use of `a`
         to in the `showA` function to the inner binding, ignoring
         the outer one.
         */
        let source = """
        var a = "global";
        {
          fun showA() {
            print a;
          }

          showA();
          var a = "block";
          showA();
        }
        """
        let env = Environment()
        let tokens = Scanner(source: source).scanTokens()
        let stmts = try Parser(tokens: tokens).parse()
        try execute(stmts, environment: env)
//        XCTAssertEqual(env.get("r1"), .number(1))
//        XCTAssertEqual(env.get("r2"), .number(2))
    }
}
