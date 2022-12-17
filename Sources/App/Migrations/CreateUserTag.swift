import Fluent

extension UserTag {
    struct Migration: AsyncMigration {
        var name: String { "CreateUserTag" }
        
        func prepare(on database: Database) async throws {
            try await database.schema(UserTag.schema)
                .id()
                .field("user_id", .uuid)
                .field("tag_id", .uuid)
                .unique(on: "user_id", "tag_id")
                .create()
        }
        
        func revert(on database: Database) async throws {
            try await database.schema(UserTag.schema).delete()
        }
    }
}
