import Fluent
import Vapor

final class Venue: Content, Model {
    static let schema = "venue"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "location")
    var location: Location
    
    @Children(for: \.$venue)
    var events: [Event]
    
    init() { }
    
    internal init(id: UUID? = nil, name: String, location: Location) {
        self.id = id
        self.name = name
        self.location = location
    }
}

struct Location: Codable {
    let latitude, longitude: Double?
}
