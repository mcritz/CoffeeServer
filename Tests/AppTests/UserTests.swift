@testable import App
import XCTVapor

final class UserTests: XCTestCase {

    var app = Application(.testing)
    
    let userNameGood = "Test McTesterface"
    let userEmailGood = "mctesterface@example.com"
    let passwordGood = "Super 5trong passw0rd!"
    var loginJWT = "FAIL"
    var headers = HTTPHeaders(dictionaryLiteral: ("Content-Type", "application/json"))
    
    override func setUpWithError() throws {
        app = Application(.testing)
        try configure(app)
    }

    override func tearDownWithError() throws {
        app.shutdown()
        headers = HTTPHeaders(dictionaryLiteral: ("Content-Type", "application/json"))
    }

    func testCreateUser() throws {
        let testUser = User.Create(name: userNameGood, email: userEmailGood, password: passwordGood, confirmPassword: passwordGood)
        let body = try JSONEncoder().encode(testUser)
        
        try app.test(.POST, "users", headers: headers, body: ByteBuffer(data: body)) { res in
            XCTAssertEqual(res.status, .ok)
            let result = try res.content.decode(User.Public.self)
            XCTAssertEqual(result.name, userNameGood)
        }
        try login()
    }
    
    func login() throws {
        let basicAuth = BasicAuthorization(username: userEmailGood, password: passwordGood)
        headers.basicAuthorization = basicAuth
        try app.test(.GET, "users/login", headers: headers) { res in
            XCTAssertEqual(res.status, .ok)
        }
    }
}
