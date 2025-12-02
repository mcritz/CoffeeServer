import Fluent
import Vapor

final class VenueController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let venuesAPI = routes.grouped("api", "v2", "venues")
        venuesAPI.get(use: index)
        venuesAPI.post(use: create)
        venuesAPI.group(":venueID") { venue in
            venue.get(use: fetchVenue)
            venue.put(use: updateVenue)
            venue.delete(use: deleteVenue)
            venue.get("events", use: venueEvents)
        }
    }
    
    func index(req: Request) async throws -> [Venue] {
        try await Venue.query(on: req.db).all()
    }
    
    func create(req: Request) async throws -> Venue {
        guard try await req.isAdmin() else {
            req.logger.warning("Unauthorized venue creation attempt\n\(req)")
            throw Abort(.unauthorized)
        }
        let venue = try req.content.decode(Venue.self)
        try await venue.save(on: req.db)
        return venue
    }
    
    func fetchVenue(req: Request) async throws -> Venue {
        guard let venueIDString = req.parameters.get("venueID"),
        let venueID = UUID(venueIDString) else {
            throw Abort(.badRequest)
        }
        guard let venue = try await Venue.find(venueID, on: req.db) else {
            throw Abort(.notFound)
        }
        return venue
    }
    
    func updateVenue(req: Request) async throws -> Venue {
        guard try await req.isAdmin() else {
            req.logger.warning("Unauthorized Venue update attempt\n\(req)")
            throw Abort(.unauthorized)
        }
        guard let venueIDString = req.parameters.get("venueID"),
              let venueID = UUID(venueIDString),
              let newVenue = try? req.content.decode(Venue.self) else {
            throw Abort(.badRequest)
        }
        guard let venue = try await Venue.find(venueID, on: req.db) else {
            throw Abort(.notFound)
        }
        venue.name = newVenue.name
        venue.location = newVenue.location
        venue.url = newVenue.url
        try await venue.update(on: req.db)
        return venue
    }
    
    func deleteVenue(req: Request) async throws -> HTTPStatus {
        guard try await req.isAdmin() else {
            req.logger.warning("Unauthorized Venue delete attempt\n\(req)")
            throw Abort(.unauthorized)
        }
        guard let venueIDString = req.parameters.get("venueID"),
        let venueID = UUID(venueIDString) else {
            throw Abort(.badRequest)
        }
        guard let venue = try await Venue.find(venueID, on: req.db) else {
            throw Abort(.notFound)
        }
        try await venue.delete(on: req.db)
        return .noContent
    }
    
    func venueEvents(req: Request) async throws -> [EventData] {
        guard let venueIDString = req.parameters.get("venueID"),
        let venueID = UUID(venueIDString) else {
            throw Abort(.badRequest)
        }
        guard let venue = try await Venue.find(venueID, on: req.db) else {
            throw Abort(.notFound)
        }
        let eventsSortedByStartTime = try await venue.$events.get(on: req.db).sorted(by: {
            $0.startAt < $1.startAt
        })
        var publicEvents = [EventData]()
        for venueEvent in eventsSortedByStartTime {
            guard let thisEvent = try? await venueEvent.publicData(db: req.db) else {
                req.logger.error(
                    "Failed to serialize Event for public listing: \(venueEvent.id?.uuidString ?? venueEvent.name)"
                )
                continue
            }
            publicEvents.append(thisEvent)
        }
        return publicEvents
    }
}
