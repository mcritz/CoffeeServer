import Fluent
import Vapor

final class InterestGroup: Model, Content, @unchecked Sendable {
    static let schema = "interestgroups"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "short")
    var short: String
    
    @Children(for: \.$group)
    var events: [Event]
    
    @Field(key: "image_url")
    var imageURL: String?
    
    @Field(key: "archived")
    var isArchived: Bool?
    
    init() { }

    internal init(id: UUID? = nil, name: String, short: String? = nil, imageURL: String? = nil, isArchived: Bool? = nil) {
        self.id = id
        self.name = name
        self.short = short ?? name.lowercased().split(separator: " ").joined(separator: "-")
        self.imageURL = imageURL
        self.isArchived = isArchived
    }
}
