import Fluent
import Vapor

struct InterestGroupController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let groupsHTML = routes.grouped("groups")
        groupsHTML.get(use: webView)
        groupsHTML.group(":groupID") { group in
            group.get("calendar.ics", use: calendar)
        }
        
        let groupsAPI = routes.grouped("api", "v2", "groups")
        groupsAPI.get(use: index)
        groupsAPI.post(use: create)
        groupsAPI.group(":groupID") { group in
            group.delete(use: delete)
            group.get("events", use: groupEvents)
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
    
    func groupEvents(req: Request) async throws -> [EventData] {
        guard let groupIDString = req.parameters.get("groupID"),
        let groupID = UUID(groupIDString) else {
            throw Abort(.badRequest)
        }
        guard let group = try await InterestGroup.find(groupID, on: req.db) else {
            throw Abort(.notFound)
        }
        let eventsSortedByStartAt = try await group.$events
            .get(on: req.db)
            .map {
                $0.publicData()
            }
            .sorted {
                $0.startAt < $1.startAt
            }
        return eventsSortedByStartAt
    }
}
