import Fluent
import Vapor

public typealias MapURL = String

final class Venue: Content, Model, @unchecked Sendable {
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
                  name: String,
                  location: Location? = nil,
                  url: MapURL? = nil) {
        self.id = id
        self.name = name
        self.location = location
        self.url = url
    }
}

struct Location: Codable {
    let description: String
    let latitude, longitude: Double?
}

extension Location: Validatable {
    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("latitude", as: Double.self, is: .range(-90.0...90.0))
        validations.add("longitude", as: Double.self, is: .range(-180.0...180.0))
    }
}
