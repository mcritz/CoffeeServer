import Fluent

extension UserTag {
    struct Migration: AsyncMigration {
        var name: String { "CreateUserTag" }
        
        func prepare(on database: Database) async throws {
            try await database.schema(UserTag.schema)
                .id()
                .field("user_id", .uuid, .required, .references(User.schema, "id"))
                .field("tag_id", .uuid, .required, .references(Tag.schema, "id"))
                .unique(on: "user_id", "tag_id")
                .create()
        }
        
        func revert(on database: Database) async throws {
            try await database.schema(UserTag.schema).delete()
        }
    }
}
