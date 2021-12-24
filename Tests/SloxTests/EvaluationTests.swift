@testable import Slox
import XCTest

final class EvaluationTests: XCTestCase {
    func expr(_ source: String) throws -> Expr {
        let tokens = Scanner(source: source).scanTokens()
        let expr = try Parser(tokens: tokens).parse()
        return expr
    }

    func testBinaryMinus() throws {
        let expr = try expr("10 - 4")
        let literal = try eval(expr)
        XCTAssertEqual(literal, .number(6))
    }

    func testBinaryPlusNumber() throws {
        let expr = try expr("10 + 4")
        let literal = try eval(expr)
        XCTAssertEqual(literal, .number(14))
    }

    func testBinaryPlusString() throws {
        let expr = try expr(#""hello" + " " + "world""#)
        let literal = try eval(expr)
        XCTAssertEqual(literal, .string("hello world"))
    }

    func testBinaryStar() throws {
        let expr = try expr("10 * 4")
        let literal = try eval(expr)
        XCTAssertEqual(literal, .number(40))
    }

    func testBinarySlash() throws {
        let expr = try expr("10 / 4")
        let literal = try eval(expr)
        XCTAssertEqual(literal, .number(2.5))
    }

    func testBinaryBangEqual() throws {
        let e1 = try expr("10 != 10")
        let l1 = try eval(e1)
        XCTAssertEqual(l1, .bool(false))

        let e2 = try expr("10 != 9")
        let l2 = try eval(e2)
        XCTAssertEqual(l2, .bool(true))
    }

    func testBinaryEqualEqualDouble() throws {
        let e1 = try expr("10 == 10")
        let l1 = try eval(e1)
        XCTAssertEqual(l1, .bool(true))

        let e2 = try expr("10 == 9")
        let l2 = try eval(e2)
        XCTAssertEqual(l2, .bool(false))
    }

    func testBinaryEqualEqualString() throws {
        let e1 = try expr(#""hello" == "world""#)
        let l1 = try eval(e1)
        XCTAssertEqual(l1, .bool(false))

        let e2 = try expr(#""hello" == "hello""#)
        let l2 = try eval(e2)
        XCTAssertEqual(l2, .bool(true))
    }

    func testBinaryGreater() throws {
        let e1 = try expr("10 > 11")
        let l1 = try eval(e1)
        XCTAssertEqual(l1, .bool(false))

        let e2 = try expr("10 > 9")
        let l2 = try eval(e2)
        XCTAssertEqual(l2, .bool(true))

        let e3 = try expr("10 > 10")
        let l3 = try eval(e3)
        XCTAssertEqual(l3, .bool(false))
    }

    func testBinaryGreaterEqual() throws {
        let e1 = try expr("10 >= 11")
        let l1 = try eval(e1)
        XCTAssertEqual(l1, .bool(false))

        let e2 = try expr("10 >= 9")
        let l2 = try eval(e2)
        XCTAssertEqual(l2, .bool(true))

        let e3 = try expr("10 >= 10")
        let l3 = try eval(e3)
        XCTAssertEqual(l3, .bool(true))
    }

    func testBinaryLessDouble() throws {
        let e1 = try expr("10 < 11")
        let l1 = try eval(e1)
        XCTAssertEqual(l1, .bool(true))

        let e2 = try expr("10 < 9")
        let l2 = try eval(e2)
        XCTAssertEqual(l2, .bool(false))

        let e3 = try expr("10 < 10")
        let l3 = try eval(e3)
        XCTAssertEqual(l3, .bool(false))
    }

    func testBinaryLessString() throws {
        let e1 = try expr(#""hello" < "world""#)
        let l1 = try eval(e1)
        XCTAssertEqual(l1, .bool(true))

        let e2 = try expr(#""too-da-loo" < "earth""#)
        let l2 = try eval(e2)
        XCTAssertEqual(l2, .bool(false))
    }

    func testBinaryLesssEqual() throws {
        let e1 = try expr("10 <= 11")
        let l1 = try eval(e1)
        XCTAssertEqual(l1, .bool(true))

        let e2 = try expr("10 <= 9")
        let l2 = try eval(e2)
        XCTAssertEqual(l2, .bool(false))

        let e3 = try expr("10 <= 10")
        let l3 = try eval(e3)
        XCTAssertEqual(l3, .bool(true))
    }

    func testGrouping() throws {
        let expr = try expr("(3 + 4) * 5")
        let literal = try eval(expr)
        XCTAssertEqual(literal, .number(35))
    }

    func testUnaryMinus() throws {
        let expr = try expr("-14")
        let literal = try eval(expr)
        XCTAssertEqual(literal, .number(-14))
    }

    func testUnaryBang() throws {
        let expr = try expr("!true")
        let literal = try eval(expr)
        XCTAssertEqual(literal, .bool(false))
    }

    func testMisMatchedBinaryTypes() throws {
        let literal = try expr("true * 5")
        XCTAssertThrowsError(try eval(literal))
    }
}
