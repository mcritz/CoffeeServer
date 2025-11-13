import Fluent
import Vapor

final class UserTag: Model, @unchecked Sendable {
    static let schema = "user+tag"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Parent(key: "tag_id")
    var tag: Tag

    init() { }

    init(id: UUID? = nil, user: User, tag: Tag) throws {
        self.id = id
        self.$user.id = try user.requireID()
        self.$tag.id = try tag.requireID()
    }
}
