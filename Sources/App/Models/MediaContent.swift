import Fluent
import Vapor

final class MediaContent: Content, Model, @unchecked Sendable {
    static let schema = "media"
    
    @ID(key: .id) var id: UUID?
    
    @Field(key: "filename")
    var filename: String
    
    @Field(key: "raw_filename")
    var rawFilename: String
    
    @Field(key: "mime_type")
    var mimeType: String
    
    @Field(key: "content_length")
    var contentLength: Int
    
    @Parent(key: "user_id")
    var user: User
    
    @OptionalParent(key: "venue_id")
    var venue: Venue?
    
    init() { }
    
    init(id: UUID? = nil,
         filename: String,
         rawFilename: String,
         mimeType: String,
         contentLength: Int,
         userID: User,
         venue: Venue? = nil) throws {
        self.id = id
        self.filename = filename
        self.rawFilename = rawFilename
        self.mimeType = mimeType
        self.contentLength = contentLength
        self.$user.id = try userID.requireID()
        self.$venue.id = try venue?.requireID()
    }
}

extension MediaContent {
    // TODO: this is brittle as heck
    func mediaType() -> HTTPMediaType? {
        let components = mimeType.split(separator: "/")
        guard let type = components.first,
              let subType = components.last else {
            return nil
        }
        return HTTPMediaType(type: String(type), subType: String(subType))
    }
}
