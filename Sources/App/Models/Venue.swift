import CoffeeKit
import Fluent
import Vapor

final class Venue: VenueRepresentable, Content, Model, @unchecked Sendable {
    static let schema = "venues"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "location")
    var location: Location?
    
    @Field(key: "url")
    var url: MapURL?
    
    @Children(for: \.$venue)
    var events: [Event]
    
    @Children(for: \.$venue)
    var media: [MediaContent]
    
    init() { }
    
    internal init(id: UUID? = nil,
                  name: String? = nil,
                  location: Location? = nil,
                  url: MapURL? = nil) {
        self.id = id
        self.name = name ?? "Unknown Venue"
        self.location = location
        self.url = url
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case location
        case url
    }

    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decodeIfPresent(UUID.self, forKey: .id)
        let name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Unknown Venue"
        let location = try container.decodeIfPresent(Location.self, forKey: .location)
        let url = try container.decodeIfPresent(MapURL.self, forKey: .url)
        self.init(id: id, name: name, location: location, url: url)
    }
}

extension Venue {
    /// Finds a `Venue` by its `.id` or `location`
    /// - Parameter db: ``Fluent.Database``
    /// - Returns: the found ``Venue`` or ``nil``
    func fetchFromModel(on db: Database) async throws -> Venue? {
        if let venueID = try? self.requireID() {
            return try await Venue.find(venueID, on: db)
        }
        
        guard let location = location else {
            return nil
        }
        return try? await Venue.query(on: db)
            .filter(\.$location == location)
            .first()
    }
}
