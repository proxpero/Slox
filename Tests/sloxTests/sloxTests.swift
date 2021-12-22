import XCTest
@testable import slox

final class sloxTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(slox().text, "Hello, World!")
    }
}
