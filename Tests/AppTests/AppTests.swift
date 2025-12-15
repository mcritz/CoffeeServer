@testable import App
import VaporTesting
import Testing

@Suite("App Tests")
struct AppTests {
    @Test("Healthcheck")
    func healthcheck() async throws {
        try await withApp(configure: configure) { app in
            try await app.testing().test(.GET, "healthcheck") { res async in
                #expect(res.status == .ok)
                #expect(res.body.string.contains("OK"))
            }
        }
    }
    
    @Test("Homepage")
    func homepage() async throws {
        try await withApp(configure: configure) { app in
            try await app.testing().test(.GET, "") { res async in
                #expect(res.status == .ok)
                #expect(res.body.string.contains("Coffee Coffee Coffee Coffee"))
            }
        }
    }
}
