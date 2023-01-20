import Fluent
import Vapor

final class Venue: Content, Model {
    static let schema = "venue"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "location")
    var location: Location?
    
    @Field(key: "url")
    var url: URL?
    
    @Children(for: \.$venue)
    var events: [Event]
    
    init() { }
    
    internal init(id: UUID? = nil, name: String, location: Location? = nil, url: URL? = nil) {
        self.id = id
        self.name = name
        self.location = location
        self.url = url
    }
}

struct Location: Codable {
    let description: String
    let latitude, longitude: Double
}

extension Location: Validatable {
    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("latitude", as: Double.self, is: .range(-90.0...90.0))
        validations.add("longitude", as: Double.self, is: .range(-180.0...180.0))
    }
}
