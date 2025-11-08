import Fluent
import Vapor

struct EventController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let eventsAPI = routes.grouped("api", "v2", "events")
        eventsAPI.get(use: index)
        eventsAPI.get("upcoming", use: future)
        eventsAPI.post(use: create)
        eventsAPI.group(":eventID") { event in
            event.delete(use: delete)
            event.get(use: fetchEvent)
        }
    }
    
    func index(req: Request) async throws -> [Event] {
        return try await Event.query(on: req.db)
            .sort(\.$endAt, .ascending)
            .all()
    }
    
    func future(req: Request) async throws -> [Event] {
        let now = Date.now
        return try await Event.query(on: req.db)
            .filter(\.$endAt, .greaterThan, now)
            .sort(\.$endAt, .ascending)
            .all()
    }
    
    func fetchEvent(req: Request) async throws -> Event {
        guard let eventIDString = req.parameters.get("eventID"),
              let eventID = UUID(eventIDString) else {
            throw Abort(.badRequest)
        }
        guard let event = try await Event.find(eventID, on: req.db) else {
            throw Abort(.notFound)
        }
        return event
    }
    
    func create(req: Request) async throws -> EventData {
        guard try await req.isAdmin() else {
            req.logger.warning("Unauthorized event creation\n\(req)")
            throw Abort(.unauthorized)
        }
        let eventData = try req.content.decode(EventData.self)
        let event = Event(id: eventData.id,
                          name: eventData.name,
                          group: eventData.groupID,
                          venue: eventData.venueID,
                          imageURL: eventData.imageURL,
                          startAt: eventData.startAt,
                          endAt: eventData.endAt)
        try await event.save(on: req.db)
        return event.publicData()
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        guard try await req.isAdmin() else {
            req.logger.warning("Unauthorized Event delete request\n\(req)")
            throw Abort(.unauthorized)
        }
        guard let eventIDString = req.parameters.get("eventID"),
              let eventID = UUID(eventIDString) else {
            throw Abort(.badRequest)
        }
        guard let event = try await Event.find(eventID, on: req.db) else {
            throw Abort(.notFound)
        }
        try await event.delete(on: req.db)
        return .noContent
    }
}
