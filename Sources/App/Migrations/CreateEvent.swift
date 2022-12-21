import Fluent

struct CreateEvent: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Event.schema)
            .id()
            .field("name", .string, .required)
            .field("image_url", .json)
            .field("start_at", .datetime, .required)
            .field("end_at", .datetime, .required)
            .field("group_id", .uuid)
            .field("venue_id", .uuid)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Event.schema)
            .delete()
    }
}
