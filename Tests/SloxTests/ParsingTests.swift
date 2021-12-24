@testable import Slox
import XCTest

final class ParsingTests: XCTestCase {
    func testNumber() throws {
        let source = "1"
        let tokens = Scanner(source: source).scanTokens()
        let expr = try Parser(tokens: tokens).parse()
        XCTAssertEqual(expr, .literal(value: .number(1.0)))
    }

    func testString() throws {
        let source = "\"abc\""
        let tokens = Scanner(source: source).scanTokens()
        let expr = try Parser(tokens: tokens).parse()
        XCTAssertEqual(expr, .literal(value: .string("abc")))
    }

    func testTrue() throws {
        let source = "true"
        let tokens = Scanner(source: source).scanTokens()
        let expr = try Parser(tokens: tokens).parse()
        XCTAssertEqual(expr, .literal(value: .bool(true)))
    }

    func testFalse() throws {
        let source = "false"
        let tokens = Scanner(source: source).scanTokens()
        let expr = try Parser(tokens: tokens).parse()
        XCTAssertEqual(expr, .literal(value: .bool(false)))
    }

    func testNil() throws {
        let source = "nil"
        let tokens = Scanner(source: source).scanTokens()
        let expr = try Parser(tokens: tokens).parse()
        XCTAssertEqual(expr, .literalNil)
    }

    func testGrouping() throws {
        let source = "3 * (4 + 2)"
        let tokens = Scanner(source: source).scanTokens()
        let expr = try Parser(tokens: tokens).parse()
        XCTAssertEqual(expr, .binary(lhs: .literal(3), op: .star, rhs: .grouping(expr: .binary(lhs: .literal(4), op: .plus, rhs: .literal(2)))))
    }

    func testUnaryBang() throws {
        let source = "!true"
        let tokens = Scanner(source: source).scanTokens()
        let expr = try Parser(tokens: tokens).parse()
        XCTAssertEqual(expr, .unary(op: .bang, rhs: .literal(true)))
    }

    func testUnaryMinus() throws {
        let source = "-5"
        let tokens = Scanner(source: source).scanTokens()
        let expr = try Parser(tokens: tokens).parse()
        XCTAssertEqual(expr, .unary(op: .minus, rhs: .literal(5)))
    }

    func testFactorSlash() throws {
        let source = "21 / 3"
        let tokens = Scanner(source: source).scanTokens()
        let expr = try Parser(tokens: tokens).parse()
        XCTAssertEqual(expr, .binary(lhs: .literal(21), op: .slash, rhs: .literal(3)))
    }

    func testFactorStar() throws {
        let source = "5 * 3"
        let tokens = Scanner(source: source).scanTokens()
        let expr = try Parser(tokens: tokens).parse()
        XCTAssertEqual(expr, .binary(lhs: .literal(5), op: .star, rhs: .literal(3)))
    }

    func testTermMinus() throws {
        let source = "21 - 3"
        let tokens = Scanner(source: source).scanTokens()
        let expr = try Parser(tokens: tokens).parse()
        XCTAssertEqual(expr, .binary(lhs: .literal(21), op: .minus, rhs: .literal(3)))
    }

    func testTermPlus() throws {
        let source = "21 + 3"
        let tokens = Scanner(source: source).scanTokens()
        let expr = try Parser(tokens: tokens).parse()
        XCTAssertEqual(expr, .binary(lhs: .literal(21), op: .plus, rhs: .literal(3)))
    }

    func testComparisonGreater() throws {
        let source = "21 > 3"
        let tokens = Scanner(source: source).scanTokens()
        let expr = try Parser(tokens: tokens).parse()
        XCTAssertEqual(expr, .binary(lhs: .literal(21), op: .greater, rhs: .literal(3)))
    }

    func testComparisonGreaterEqal() throws {
        let source = "21 >= 3"
        let tokens = Scanner(source: source).scanTokens()
        let expr = try Parser(tokens: tokens).parse()
        XCTAssertEqual(expr, .binary(lhs: .literal(21), op: .greaterEqual, rhs: .literal(3)))
    }

    func testComparisonLess() throws {
        let source = "2 < 13"
        let tokens = Scanner(source: source).scanTokens()
        let expr = try Parser(tokens: tokens).parse()
        XCTAssertEqual(expr, .binary(lhs: .literal(2), op: .less, rhs: .literal(13)))
    }

    func testComparisonLessEqual() throws {
        let source = "2 <= 13"
        let tokens = Scanner(source: source).scanTokens()
        let expr = try Parser(tokens: tokens).parse()
        XCTAssertEqual(expr, .binary(lhs: .literal(2), op: .lessEqual, rhs: .literal(13)))
    }

    func testEqualityEqualEqual() throws {
        let source = "2 == 13"
        let tokens = Scanner(source: source).scanTokens()
        let expr = try Parser(tokens: tokens).parse()
        XCTAssertEqual(expr, .binary(lhs: .literal(2), op: .equalEqual, rhs: .literal(13)))
    }

    func testEqualityBangEqual() throws {
        let source = "2 != 13"
        let tokens = Scanner(source: source).scanTokens()
        let expr = try Parser(tokens: tokens).parse()
        XCTAssertEqual(expr, .binary(lhs: .literal(2), op: .bangEqual, rhs: .literal(13)))
    }
}

final class ParsingErrorTests: XCTestCase {
    func testMissingClosingParen() throws {
        let source = "(2 + 3"
        let tokens = Scanner(source: source).scanTokens()
        XCTAssertThrowsError(try Parser(tokens: tokens).parse())
    }
}

extension Expr {
    static func binary(lhs: Expr, op: TokenType, rhs: Expr) -> Expr {
        .binary(lhs: lhs, op: .init(type: op, line: 1), rhs: rhs)
    }

    static func unary(op: TokenType, rhs: Expr) -> Expr {
        .unary(op: .init(type: op, line: 1), rhs: rhs)
    }
}
