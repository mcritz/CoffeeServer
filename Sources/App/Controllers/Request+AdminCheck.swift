import Fluent
import JWT
import Vapor

extension Request {
    func isAdmin() async throws -> Bool {
        let jwtPayload = try jwt.verify(as: SessionJWTToken.self)
        async let requestUser = User.find(jwtPayload.userId, on: db)
        let adminTag = try await Tag.query(on: db)
            .filter(\.$name == "admin")
            .first()
        let tags = try await requestUser?.$tags.get(on: db)
        guard let tags,
                tags.contains(where: { $0.id == adminTag?.id }) else {
            return false
        }
        return true
    }
}
