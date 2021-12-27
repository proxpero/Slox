indirect enum Stmt: Equatable {
    case block([Stmt])
    case expr(Expr)
    case `if`(conditon: Expr, then: Stmt, else: Stmt?)
    case print(Expr)
    case variable(String, Expr?)
    case `while`(condition: Expr, body: Stmt)
}
