import Fluent
import Vapor

final class InterestGroup: Model, Content {
    static let schema = "interestgroup"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Children(for: \.$group)
    var events: [Event]
    
    @Field(key: "image_url")
    var imageURL: String?
    
    init() { }

    internal init(id: UUID? = nil, name: String, imageURL: String? = nil) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
    }
}
