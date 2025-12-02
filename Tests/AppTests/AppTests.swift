@testable import App
import XCTVapor

@available(macOS 13.0, *)
final class AppTests: XCTestCase {
    func testHealthCheck() async throws {
        let app = try await Application.make()
        defer {
            Task {
                try await app.asyncShutdown()
            }
        }
        try configure(app)
        
        let res = try await app.performTest(
            request: .init(
                method: .GET,
                url: "healthcheck",
                headers: .defaultHeaders,
                body: .init()
            )
        )
        
        XCTAssertEqual(res.status, .ok)
        var expected = try Regex("OK")
        XCTAssertTrue((res.body.string.firstMatch(of: expected) != nil))
    }
}
