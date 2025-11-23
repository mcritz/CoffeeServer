import Fluent
import Vapor

struct InterestGroupController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let groupsHTML = routes.grouped("groups")
        groupsHTML.get(use: webView)
        groupsHTML.group(":groupID") { group in
            group.get(use: webViewSingle)
            group.get("calendar.ics", use: calendar)
        }
        
        let groupsAPI = routes.grouped("api", "v2", "groups")
        groupsAPI.get(use: index)
        groupsAPI.post(use: create)
        groupsAPI.group(":groupID") { group in
            group.get(use: fetch)
            group.put(use: update)
            group.delete(use: delete)
            group.get("events", use: groupEvents)
        }
    }

    func index(req: Request) async throws -> [InterestGroup] {
        try await InterestGroup.query(on: req.db).all()
    }
    
    func fetch(req: Request) async throws -> InterestGroup {
        guard let groupIDString = req.parameters.get("groupID"),
              let groupUUID = UUID(groupIDString),
              let group = try await InterestGroup.find(groupUUID, on: req.db) else {
            throw Abort(.notFound)
        }
        return group
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
    
    func update(req: Request) async throws -> InterestGroup {
        guard try await req.isAdmin() else {
            req.logger.warning("Unauthorized update attempt\n\t\(req)")
            throw Abort(.unauthorized)
        }
        guard let newData = try? req.content.decode(InterestGroup.self),
              let groupIDString = req.parameters.get("groupID"),
              let groupUUID = UUID(groupIDString) else {
            throw Abort(.badRequest)
        }
        guard let group = try await InterestGroup.find(groupUUID, on: req.db) else {
            throw Abort(.notFound)
        }
        group.name = newData.name
        group.imageURL = newData.imageURL
        // events cannot be edited on the group
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
//        guard let group = try await InterestGroup.find(groupID, on: req.db) else {
//            throw Abort(.notFound)
//        }
//        let eventsSortedByStartAt = try await group.$events
//            .get(on: req.db)
//            .map {
//                $0.publicData()
//            }
//            .sorted {
//                $0.startAt < $1.startAt
//            }
        let eventsSortedByStartAt = try await Event.query(on: req.db)
            .with(\.$group)
            .filter(\.$group.$id == groupID)
            .with(\.$venue)
            .sort(\.$startAt)
            .all()
            .map {
                EventData(
                    id: $0.id,
                    name: $0.name,
                    groupID: try $0.group.requireID(),
                    venue: $0.venue,
                    imageURL: $0.imageURL,
                    startAt: $0.startAt,
                    endAt: $0.endAt
                )
            }
        
        return eventsSortedByStartAt
    }
}
