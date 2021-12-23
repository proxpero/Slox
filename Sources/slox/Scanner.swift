class Scanner {
    let source: String
    private(set) var tokens: [Token] = []
    private(set) var line = 1

    private var current: String.Index
    private var start: String.Index

    init(source: String) {
        self.source = source
        self.current = source.startIndex
        self.start = source.startIndex
    }

    func scanTokens() -> [Token] {
        while !isAtEnd {
            start = current
            scanToken()
        }
        tokens.append(.init(type: .eof, line: line))
        return tokens
    }
}

extension Scanner {
    private func scanToken() {
        let char = advance()
        switch char {
        case "(":
            addToken(.leftParen)
        case ")":
            addToken(.rightParen)
        case "{":
            addToken(.leftBrace)
        case "}":
            addToken(.rightBrace)
        case ",":
            addToken(.comma)
        case ".":
            addToken(.dot)
        case "-":
            addToken(.minus)
        case "+":
            addToken(.plus)
        case ";":
            addToken(.semicolon)
        case "*":
            addToken(.star)
        case "!":
            addToken(match("=") ? .bangEqual : .bang)
        case "=":
            addToken(match("=") ? .equalEqual : .equal)
        case "<":
            addToken(match("=") ? .lessEqual : .less)
        case ">":
            addToken(match("=") ? .greaterEqual : .greater)

        case "/":
            // Comment
            if match("/") {
                while peek != "\n", !isAtEnd { advance() }
            } else {
                addToken(.slash)
            }

        // Ignore whitespace.
        case " ":
            break
        case "\r":
            break
        case "\t":
            break
        case "\n":
            line += 1

        case "\"":
            addStringToken()

        case _ where char.isNumber:
            addNumberToken()

        case _ where char.isLetter || char == "_":
            addIdentifier()

        default:
            Slox.error(line, "Unexpected character: \(char)")
        }
    }

    private func addToken(_ tokenType: TokenType) {
        tokens.append(.init(type: tokenType, line: line))
    }
}

private extension Character {
    var isDigit: Bool {
        isNumber && isASCII
    }

    var isAlpha: Bool {
        isASCII && (isLetter || self == "_")
    }

    var isAlphanumeric: Bool {
        isDigit || isAlpha
    }
}

extension Scanner {
    @discardableResult
    private func advance() -> Character {
        defer { current = source.index(after: current) }
        return source[current]
    }

    private var peek: Character {
        guard current != source.endIndex else { return "\0" }
        return source[current]
    }

    private var peekNext: Character {
        let next = source.index(after: current)
        guard next != source.endIndex else { return "\0" }
        return source[next]
    }

    private func match(_ expected: Character) -> Bool {
        guard !isAtEnd, source[current] == expected else { return false }
        current = source.index(after: current)
        return true
    }

    private var isAtEnd: Bool {
        current == source.endIndex
    }

    private var currentText: String {
        String(source[start ..< current])
    }

    private func addStringToken() {
        while peek != "\"", !isAtEnd {
            if peek == "\n" { line += 1 }
            advance()
        }

        if isAtEnd {
            Slox.error(line, "Unterminated string.")
            return
        }

        // The closing '"'
        advance()

        addToken(.string(currentText))
    }

    private func addNumberToken() {
        while peek.isDigit { advance() }
        if peek == ".", peekNext.isDigit {
            // consumer the '.'
            advance()
            while peek.isDigit { advance() }
        }
        guard let value = Double(currentText) else {
            fatalError()
        }
        addToken(.number(value))
    }

    private func addIdentifier() {
        while peek.isAlphanumeric {
            advance()
        }

        let type: TokenType
        switch currentText {
        case "and": type = .and
        case "class": type = .class
        case "else": type = .else
        case "false": type = .false
        case "for": type = .for
        case "fun": type = .fun
        case "if": type = .if
        case "nil": type = .nil
        case "or": type = .or
        case "print": type = .print
        case "return": type = .return
        case "super": type = .super
        case "this": type = .this
        case "true": type = .true
        case "var": type = .var
        case "while": type = .while
        default: type = .identifier(currentText)
        }

        addToken(type)
    }
}
