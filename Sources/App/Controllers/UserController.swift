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
        protectedUsers.delete(":userID", use: delete)
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
    
    func delete(_ req: Request) async throws -> HTTPStatus {
        let payload = try req.jwt.verify(as: SessionJWTToken.self)
        guard let requestingUser = try await User.find(payload.userId, on: req.db) else {
            req.logger.info("Unauthorized user delete attempt\n\(req)")
            throw Abort(.unauthorized)
        }
        guard let userIdString = req.parameters.get("userID"),
              let userIdToDelete = UUID(userIdString),
                let user = try await User.find(userIdToDelete, on: req.db) else {
            throw Abort(.badRequest, reason: "Cannot find userID")
        }
        if try requestingUser.requireID() == userIdToDelete {
            try await user.delete(on: req.db)
            req.logger.info("User requests to self-delete. UserID \(userIdString)")
            return .noContent
        }
        if try await req.isAdmin() {
            req.logger.info("Admin delete of user \(userIdString)")
            try await user.delete(on: req.db)
            return .noContent
        }
        req.logger.info("Unauthorized attempt to delete user\n\(req)")
        return .unauthorized
    }
}

// MARK: - Auth
extension UserController {
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
}

// MARK: - Tags
extension UserController {
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
