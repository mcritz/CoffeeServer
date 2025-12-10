import CoffeeKit
import Testing
import VaporTesting

@testable import App

@Suite("User Tests")
final class UserTests {

    var userJWT = "NOT SET"
    
    let createdUser = UserCreate(
        name: "Edgar A. Poe",
        email: "ellanore@nevermore.com",
        password: "T1ck T0ck Horrible Heart!",
        confirmPassword: "T1ck T0ck Horrible Heart!"
    )

    @Test("User Create")
    func userCreate() async throws {
        try await withApp(configure: configure) { app in
            let createUserData = try JSONEncoder().encode(createdUser)
            let createUserBody = ByteBuffer(data: createUserData)
            try await app.testing().test(
                .POST,
                "/api/v2/users",
                headers: ["Content-Type": "application/json"],
                body: createUserBody
            ) { res async in
                #expect(res.status == .created, "expected HTTP 201 Created")
                let bodyData = Data(buffer: res.body)
                let user = try? JSONDecoder().decode(UserPublic.self, from: bodyData)
                #expect(user != nil)
                #expect(user?.id != nil)
            }
        }
    }
    
    @Test("User Login")
    func userLogin() async throws {
        try await withApp(configure: configure) { app in
            let createUserData = try JSONEncoder().encode(createdUser)
            let createUserBody = ByteBuffer(data: createUserData)
            try await app.testing().test(
                .POST,
                "/api/v2/users",
                headers: ["Content-Type": "application/json"],
                body: createUserBody
            ) { res async in
                #expect(res.status == .created, "expected HTTP 201 Created")
                let bodyData = Data(buffer: res.body)
                let user = try? JSONDecoder().decode(UserPublic.self, from: bodyData)
                #expect(user != nil)
                #expect(user?.id != nil)
            }
            
            let badEncodedPassword = Data("WRONG PASSWORD".utf8).base64EncodedString()
            try await app.testing().test(
                .POST,
                "/api/v2/users/login",
                headers: [
                    "Authorization" : "Basic \(badEncodedPassword)"
                ]) { res in
                    #expect(res.status == .unauthorized, "Responds `unauthorized` for bad passwords")
                }
            
            let encodedLogin = Data("\(createdUser.email):\(createdUser.password)".utf8)
                .base64EncodedString()
            try await app.testing().test(
                .POST,
                "/api/v2/users/login",
                headers: [
                    "Authorization" : "Basic \(encodedLogin)"
                ]) { res in
                    #expect(res.status == .ok, "Responds `ok` for valid login")
                    let responseBodyData = Data(buffer: res.body)
                    let responseJSON: [String: String] = try JSONDecoder().decode(
                        [String: String].self,
                        from: responseBodyData
                    )
                    #expect(!responseJSON.isEmpty, "Response is a valid JSON object")
                    let jwtToken = responseJSON["jwt-token"]
                    #expect(jwtToken != nil, "Response JSON includes `jwt-token`")
                    self.userJWT = jwtToken!
                }
            
            try await app.testing().test(
                .GET,
                "/api/v2/users/me",
                headers: [
                    "Authorization" : "Bearer \(self.userJWT)"
                ]) { res async in
                    #expect(res.status == .ok, "Responds `ok` for fetching self")
                    
                    let responseData = Data(buffer: res.body)
                    let user: UserPublic? = try? JSONDecoder().decode(UserPublic.self, from: responseData)
                    guard let user else {
                        #expect(true == false, "Response did not include `UserPublic` response")
                        return
                    }
                    #expect(user.id != nil, "User has an .id")
                    #expect(user.name == createdUser.name, "User's name matches created user")
                }
        }
    }
}
