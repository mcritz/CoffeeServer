import Fluent
import Vapor

struct EventController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let eventsAPI = routes.grouped("api", "v2", "events")
        eventsAPI.get(use: index)
        eventsAPI.get("upcoming", use: future)
        eventsAPI.post(use: create)
        eventsAPI.group(":eventID") { event in
            event.put(use: update)
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
            let eventID = UUID(eventIDString)
        else {
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
        guard let groupID = eventData.groupID else {
            throw Abort(.badRequest, reason: "Event must be associated with a group")
        }
        
        guard let existingGroup = try await InterestGroup.find(groupID, on: req.db) else {
            throw Abort(.notFound, reason: "No group with id \(groupID)")
        }
        
        let event = Event(
            id: eventData.id,
            name: eventData.name,
            group: try existingGroup.requireID(),
            imageURL: eventData.imageURL,
            startAt: eventData.startAt,
            endAt: eventData.endAt
        )
        
        guard let venueID = eventData.venueID,
                let existingVenue = try await Venue.find(venueID, on: req.db) else {
            throw Abort(.badRequest, reason: "Venue is required")
        }
        
        event.$venue.id = try existingVenue.requireID()
        
        try await event.save(on: req.db)
        return event.publicData()
    }
    
    func update(req: Request) async throws -> EventData {
        guard try await req.isAdmin() else {
            req.logger.warning("Unauthorized Event edit request\n\(req)")
            throw Abort(.unauthorized)
        }
        guard let eventIDString = req.parameters.get("eventID"),
            let eventID = UUID(eventIDString)
        else {
            throw Abort(.badRequest)
        }
        let eventData = try req.content.decode(EventData.self)
        
        async let event = Event.find(eventID, on: req.db)
        async let group = InterestGroup.find(eventData.groupID, on: req.db)
        async let venue = Venue.find(eventData.venueID, on: req.db)
        
        guard let event = try await event,
              let group = try await group,
              let venue = try await venue else {
            throw Abort(.notFound)
        }
        event.name = eventData.name
        event.group?.id = try? group.requireID()
        event.venue?.id = try? venue.requireID()
        event.imageURL = eventData.imageURL
        try await event.update(on: req.db)
        return event.publicData()
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard try await req.isAdmin() else {
            req.logger.warning("Unauthorized Event delete request\n\(req)")
            throw Abort(.unauthorized)
        }
        guard let eventIDString = req.parameters.get("eventID"),
            let eventID = UUID(eventIDString)
        else {
            throw Abort(.badRequest)
        }
        guard let event = try await Event.find(eventID, on: req.db) else {
            throw Abort(.notFound)
        }
        try await event.delete(on: req.db)
        return .noContent
    }
}
