import Fluent
import Vapor

struct InterestGroupController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let groups = routes.grouped("groups")
        groups.get(use: index)
        groups.post(use: create)
        groups.group(":groupID") { group in
            group.delete(use: delete)
        }
    }

    func index(req: Request) async throws -> [InterestGroup] {
        try await InterestGroup.query(on: req.db).all()
    }

    func create(req: Request) async throws -> InterestGroup {
        guard try await req.isAdmin() else {
            req.logger.info("Failed Group create \(req)")
            throw Abort(.unauthorized)
        }
        let group = try req.content.decode(InterestGroup.self)
        try await group.save(on: req.db)
        return group
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard try await req.isAdmin() else {
            req.logger.info("Failed Group delete \(req)")
            throw Abort(.unauthorized)
        }
        guard let group = try await InterestGroup.find(req.parameters.get("groupID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await group.delete(on: req.db)
        return .noContent
    }
}
