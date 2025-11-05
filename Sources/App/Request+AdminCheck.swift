import Fluent
import JWT
import Vapor

extension Request {
    func isAdmin() async throws -> Bool {
        let jwtPayload = try jwt.verify(as: SessionJWTToken.self)
        async let requestUserTags = User.find(jwtPayload.userId, on: db)?
            .$tags
            .get(on: db)
        async let adminTag = try Tag.query(on: db)
            .filter(\.$name == "admin")
            .first()
        guard let userTags = try await requestUserTags,
              let adminTagID = try await adminTag?.requireID(),
              userTags.contains(where: { $0.id == adminTagID }) else {
            return false
        }
        return true
    }
}
