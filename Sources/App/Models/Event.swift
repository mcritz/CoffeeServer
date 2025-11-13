import Fluent
import Vapor

struct EventData: Codable {
    var id: UUID?
    var name: String
    var groupID: UUID?
    var venueID: UUID?
    var venue: Venue?
    var imageURL: URL?
    var startAt: Date
    var endAt: Date
}

extension EventData: Content { }

extension EventData: AsyncResponseEncodable {
    func encodeResponse(for request: Vapor.Request) async throws -> Vapor.Response {
        let body = try JSONEncoder().encode(self)
        let jsonHeader = HTTPHeaders.init(dictionaryLiteral: ("Content-Type", "application/json"))
        return Response(headers: jsonHeader, body: .init(data: body))
    }
}

final class Event: Model, Content, @unchecked Sendable {
    static let schema = "events"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String
    
    @OptionalParent(key: "group_id")
    var group: InterestGroup?
    
    @OptionalParent(key: "venue_id")
    var venue: Venue?
    
    @Field(key: "image_url")
    var imageURL: URL?
    
    @Field(key: "start_at")
    var startAt: Date
    
    @Field(key: "end_at")
    var endAt: Date
    
    init() { }

    init(id: UUID? = nil,
         name: String,
         group: InterestGroup.IDValue? = nil,
         venue: Venue.IDValue? = nil,
         imageURL: URL? = nil,
         startAt: Date,
         endAt: Date) {
        self.id = id
        self.name = name
        self.$group.id = group
        self.$venue.id = venue
        self.imageURL = imageURL
        self.startAt = startAt
        self.endAt = endAt
    }
}

extension Event {
    func publicData() -> EventData {
        return .init(id: self.id,
                     name: self.name,
                     groupID: self.group?.id,
                     venueID: self.venue?.id,
                     imageURL: self.imageURL,
                     startAt: self.startAt,
                     endAt: self.endAt)
    }
}
