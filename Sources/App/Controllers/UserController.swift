import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        let basicProtectd = users.grouped(UserBasicAuthenticator())
        let protectedUsers = users.grouped(SessionJWTToken.authenticator(), SessionJWTToken.guardMiddleware())

        users.post(use: create)
        
        basicProtectd.get("login", use: login)
        
        protectedUsers.get(use: index)
        protectedUsers.get(":userID", use: fetch)
        protectedUsers.get("me", use: fetchSelf)
        protectedUsers.get(":userID", "tags", use: getTags)
    }
    
    func index(_ req: Request) async throws -> [User.Public] {
        guard try await req.isAdmin() else {
            throw Abort(.unauthorized)
        }
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
        let payload = try req.jwt.verify(as: SessionJWTToken.self)
        guard let user = try await User.find(payload.userId, on: req.db) else {
            throw Abort(.badRequest)
        }
        return user.publicValue()
    }
    
    func login(_ req: Request) async throws -> [String : String] {
        do {
            let user = try req.auth.require(User.self)
            let tags = try await user.$tags.get(on: req.db)
            let token = try SessionJWTToken(user: user, tags: tags)
            let signedToken = try req.jwt.sign(token)
            
            req.logger.info("User login: \(user.id?.uuidString ?? "no id")")
            
            return [
                "error" : "false",
                "message" : "logged in as \(user.name)",
                "jwt-token" : signedToken
            ]
        } catch {
            req.logger.warning("Login failure \(req)")
            return [
                "error" : "true",
                "message" : error.localizedDescription
            ]
        }
    }
    
    func getTags(_ req: Request) async throws -> [Tag] {
        guard try await req.isAdmin() else {
            throw Abort(.unauthorized)
        }
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return try await user.$tags.get(on: req.db)
    }
}
