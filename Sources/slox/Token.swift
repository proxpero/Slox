enum TokenType: Equatable {
    // single-character tokens.
    case comma
    case dot
    case leftParen
    case rightParen
    case leftBrace
    case rightBrace
    case minus
    case plus
    case semicolon
    case slash
    case star

    // one or two character tokens.
    case bang
    case bangEqual
    case equal
    case equalEqual
    case greater
    case greaterEqual
    case less
    case lessEqual

    // literals.
    case identifier(String)
    case number(Double)
    case string(String)

    // keywords
    case and
    case `class`
    case `else`
    case `false`
    case `for`
    case fun
    case `if`
    case `nil`
    case or
    case print
    case `return`
    case `super`
    case this
    case `true`
    case `var`
    case `while`

    case eof
}

struct Token: Equatable {
    let type: TokenType
    let line: Int
}

extension Token {
    var lexeme: String {
        switch type {
        case .comma:
            return ","
        case .dot:
            return "."
        case .leftParen:
            return "("
        case .rightParen:
            return ")"
        case .leftBrace:
            return "{"
        case .rightBrace:
            return "}"
        case .minus:
            return "-"
        case .plus:
            return "+"
        case .semicolon:
            return ";"
        case .slash:
            return "/"
        case .star:
            return "*"
        case .bang:
            return "!"
        case .bangEqual:
            return "!="
        case .equal:
            return "="
        case .equalEqual:
            return "!="
        case .greater:
            return ">"
        case .greaterEqual:
            return ">="
        case .less:
            return "<"
        case .lessEqual:
            return "<="
        case .identifier(let value):
            return value
        case .number(let value):
            return String(value)
        case .string(let value):
            return value
        case .and:
            return "and"
        case .class:
            return "class"
        case .else:
            return "else"
        case .false:
            return "false"
        case .for:
            return "for"
        case .fun:
            return "fun"
        case .if:
            return "if"
        case .nil:
            return "nil"
        case .or:
            return "or"
        case .print:
            return "print"
        case .return:
            return "return"
        case .super:
            return "super"
        case .this:
            return "this"
        case .true:
            return "true"
        case .var:
            return "var"
        case .while:
            return "while"
        case .eof:
            return ""
        }
    }
}
