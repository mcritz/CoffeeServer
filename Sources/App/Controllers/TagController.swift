import Fluent
import Vapor

final class TagController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let tags = routes.grouped("tags")
        tags.get(use: index)
        tags.post(use: create)
        tags.group(":tagID") { tag in
            tag.get(use: fetch)
            tag.delete(use: delete)
        }
        tags.post(":tagID", "attach", ":userID", use: attachUser)
    }
    
    func index(req: Request) async throws -> [Tag] {
        try await Tag.query(on: req.db).all()
    }
    
    func create(req: Request) async throws -> Tag {
        let tag = try req.content.decode(Tag.self)
        try await tag.save(on: req.db)
        return tag
    }
    
    func fetch(req: Request) async throws -> Tag {
        guard let tag = try await Tag.find(req.parameters.get("tagID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return tag
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        guard let tag = try await Tag.find(req.parameters.get("tagID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await tag.delete(on: req.db)
        return .noContent
    }
    
    func attachUser(req: Request) async throws -> HTTPStatus {
        guard let tagString = req.parameters.get("tagID"),
              let tagID = UUID(uuidString: tagString),
              let userString = req.parameters.get("userID"),
              let userID = UUID(uuidString: userString) else {
            throw Abort(.badRequest)
        }
        async let user = User.find(userID, on: req.db)
        async let tag = Tag.find(tagID, on: req.db)
        guard try await tag != nil,
              try await user != nil else {
            throw Abort(.notFound)
        }
        try await user!.$tags.attach(tag!, on: req.db)
        return .created
    }
}
