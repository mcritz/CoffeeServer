import JWT
import Vapor

struct SessionJWTToken: Content, Authenticatable, JWTPayload {
    let expirationTime: TimeInterval

    var expiration: ExpirationClaim
    var userId: UUID

    init(userId: UUID, expirationTime: TimeInterval = 60 * 15) {
        self.userId = userId
        self.expirationTime = expirationTime
        self.expiration = ExpirationClaim(value: Date().addingTimeInterval(expirationTime))
    }

    init(user: User, expirationTime: TimeInterval = 60 * 15) throws {
        self.userId = try user.requireID()
        self.expirationTime = expirationTime
        self.expiration = ExpirationClaim(value: Date().addingTimeInterval(expirationTime))
    }

    func verify(using signer: JWTSigner) throws {
        try expiration.verifyNotExpired()
    }
}
