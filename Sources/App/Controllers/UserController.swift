import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        let basicProtectd = routes.grouped(UserBasicAuthenticator())
        let protectedUsers = routes.grouped(SessionJWTToken.authenticator(), SessionJWTToken.guardMiddleware())

        
        users.get(use: index)
        users.get(":userID", use: fetch)
        users.post(use: create)
        protectedUsers.get("users", "me", use: fetchSelf)
        basicProtectd.get("users", "login", use: login)
        users.get(":userID", "tags", use: getTags)
    }
    
    func index(_ req: Request) async throws -> [User.Public] {
        let users = try await User.query(on: req.db).all()
        return users.map { $0.publicValue() }
    }
    
    func create(_ req: Request) async throws -> User.Public {
        try User.Create.validate(content: req)
        let create = try req.content.decode(User.Create.self)
        guard create.password == create.confirmPassword else {
            throw Abort(.badRequest, reason: "Passwords did not match")
        }
        let user = try User(
            name: create.name,
            email: create.email,
            passwordHash: Bcrypt.hash(create.password)
        )
        try await user.save(on: req.db)
        return user.publicValue()
    }
    
    func fetch(_ req: Request) async throws -> User.Public {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return user.publicValue()
    }
    
    func fetchSelf(_ req: Request) async throws -> User.Public {
//        try req.auth.require(User.self).publicValue()
        let payload = try req.jwt.verify(as: SessionJWTToken.self)
        guard let user = try await User.find(payload.userId, on: req.db) else {
            throw Abort(.badRequest)
        }
        return user.publicValue()
    }
    
    func login(_ req: Request) async throws -> [String : String] {
        let user = try req.auth.require(User.self)
        let token = try SessionJWTToken(user: user)
        let signedToken = try req.jwt.sign(token)
        
        return [
            "status" : "success",
            "jwt-token" : signedToken
        ]
    }
    
    func getTags(_ req: Request) async throws -> [Tag] {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return try await user.$tags.get(on: req.db)
    }
}

/**
app.post("users") { req async throws -> User in
    try User.Create.validate(content: req)
    let create = try req.content.decode(User.Create.self)
    guard create.password == create.confirmPassword else {
        throw Abort(.badRequest, reason: "Passwords did not match")
    }
    let user = try User(
        name: create.name,
        email: create.email,
        passwordHash: Bcrypt.hash(create.password)
    )
    try await user.save(on: req.db)
    return user
}
 */
