@testable import Slox
import XCTest

final class ScanningTests: XCTestCase {
    func testIdentifiers() {
        let source = """
        andy formless fo _ _123 _abc ab123
        abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_

        """
        let tokens = Scanner(source: source).scanTokens()
        let expected: [Token] = [
            .init(type: .identifier("andy"), line: 1),
            .init(type: .identifier("formless"), line: 1),
            .init(type: .identifier("fo"), line: 1),
            .init(type: .identifier("_"), line: 1),
            .init(type: .identifier("_123"), line: 1),
            .init(type: .identifier("_abc"), line: 1),
            .init(type: .identifier("ab123"), line: 1),
            .init(type: .identifier("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_"), line: 2),
            .init(type: .eof, line: 3),
        ]
        XCTAssertEqual(tokens, expected)
    }

    func testKeywords() {
        let source = "and class else false for fun if nil or return super this true var while"
        let tokens = Scanner(source: source).scanTokens()
        let expected: [Token] = [
            .and, .class, .else, .false, .for, .fun, .if, .nil, .or, .return, .super, .this, .true, .var, .while, .eof,
        ].map { Token(type: $0, line: 1) }
        XCTAssertEqual(tokens, expected)
    }

    func testNumbers() {
        let source = """
        123
        123.456
        .456
        123.

        """
        let tokens = Scanner(source: source).scanTokens()
        let expected: [Token] = [
            .init(type: .number(123.0), line: 1),
            .init(type: .number(123.456), line: 2),
            .init(type: .dot, line: 3),
            .init(type: .number(456.0), line: 3),
            .init(type: .number(123.0), line: 4),
            .init(type: .dot, line: 4),
            .init(type: .eof, line: 5),
        ]
        XCTAssertEqual(tokens, expected)
    }

    func testPunctuators() {
        let source = """
        (){};,+-*!===<=>==!<>/.
        """
        let tokens = Scanner(source: source).scanTokens()
        let expected: [Token] = [
            .init(type: .leftParen, line: 1),
            .init(type: .rightParen, line: 1),
            .init(type: .leftBrace, line: 1),
            .init(type: .rightBrace, line: 1),
            .init(type: .semicolon, line: 1),
            .init(type: .comma, line: 1),
            .init(type: .plus, line: 1),
            .init(type: .minus, line: 1),
            .init(type: .star, line: 1),
            .init(type: .bangEqual, line: 1),
            .init(type: .equalEqual, line: 1),
            .init(type: .lessEqual, line: 1),
            .init(type: .greaterEqual, line: 1),
            .init(type: .equal, line: 1),
            .init(type: .bang, line: 1),
            .init(type: .less, line: 1),
            .init(type: .greater, line: 1),
            .init(type: .slash, line: 1),
            .init(type: .dot, line: 1),
            .init(type: .eof, line: 1),
        ]
        XCTAssertEqual(tokens, expected)
    }

    func testStrings() {
        let source = #"""
        ""
        "string"
        """#
        let tokens = Scanner(source: source).scanTokens()
        let expected: [Token] = [
            .init(type: .string(""), line: 1),
            .init(type: .string("string"), line: 2),
            .init(type: .eof, line: 2),
        ]
        XCTAssertEqual(tokens, expected)
    }

    func testWhitespace() {
        let source = """
        space    tabs                newlines




        end
        """
        let tokens = Scanner(source: source).scanTokens()
        let expected: [Token] = [
            .init(type: .identifier("space"), line: 1),
            .init(type: .identifier("tabs"), line: 1),
            .init(type: .identifier("newlines"), line: 1),
            .init(type: .identifier("end"), line: 6),
            .init(type: .eof, line: 6),
        ]
        XCTAssertEqual(tokens, expected)
    }

    func testBraces() {
        let source = """
        if true {
            y = 2;
        }
        """
        let tokens = Scanner(source: source).scanTokens()
        let expected: [Token] = [
            .init(type: .if, line: 1),
            .init(type: .true, line: 1),
            .init(type: .leftBrace, line: 1),
            .init(type: .identifier("y"), line: 2),
            .init(type: .equal, line: 2),
            .init(type: .number(2), line: 2),
            .init(type: .semicolon, line: 2),
            .init(type: .rightBrace, line: 3),
            .init(type: .eof, line: 3),
        ]
        XCTAssertEqual(tokens, expected)
    }

    func testErrors() {
        let source = "\"hello\" + 4"
        let tokens = Scanner(source: source).scanTokens()
        let expected: [Token] = [
            .init(type: .string("hello"), line: 1),
            .init(type: .plus, line: 1),
            .init(type: .number(4), line: 1),
            .init(type: .eof, line: 1),
        ]
        XCTAssertEqual(tokens, expected)
    }
}
