import Fluent
import Vapor

final class BearerToken: Model, Content, @unchecked Sendable {
    static let schema = "bearer-tokens"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "token")
    var value: String

    init() { }

    init(id: UUID? = nil, value: String) {
        self.id = id
        self.value = value
    }
}

extension BearerToken {
    static func generateToken() throws -> String {
        guard let uuidData = UUID().uuidString.data(using: .utf8) else {
            throw Abort(.internalServerError, reason: "could not generate bearer token")
        }
        return SHA256.hash(data: uuidData).description
    }
}
