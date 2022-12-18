import JWT
import Vapor

fileprivate extension TimeInterval {
    static let defaultExpiration: Double = 60 * 15 // seconds
}

struct SessionJWTToken: Content, Authenticatable, JWTPayload {
    let expirationTime: TimeInterval

    var expiration: ExpirationClaim
    var userId: UUID
    var tags: [Tag]?

    init(userId: UUID, tags: [Tag]? = nil, expirationTime: TimeInterval = .defaultExpiration) {
        self.userId = userId
        self.expirationTime = expirationTime
        self.expiration = ExpirationClaim(value: Date().addingTimeInterval(expirationTime))
    }

    init(user: User, tags: [Tag]? = nil, expirationTime: TimeInterval = .defaultExpiration) throws {
        self.userId = try user.requireID()
        self.tags = tags
        self.expirationTime = expirationTime
        self.expiration = ExpirationClaim(value: Date().addingTimeInterval(expirationTime))
    }

    func verify(using signer: JWTSigner) throws {
        try expiration.verifyNotExpired()
    }
}
