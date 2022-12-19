@testable import App
import XCTVapor

@available(macOS 13.0, *)
final class AppTests: XCTestCase {
    func testHealthCheck() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        try app.test(.GET, "healthcheck", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let expected = try Regex("OK")
            XCTAssertTrue((res.body.string.firstMatch(of: expected) != nil))
        })
    }
}
