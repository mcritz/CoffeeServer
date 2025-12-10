import Fluent

struct CreateEvent: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Event.schema)
            .id()
            .field("name", .string, .required)
            .field("image_url", .string)
            .field("start_at", .datetime, .required)
            .field("end_at", .datetime, .required)
            .field("group_id", .uuid, .required, .references(InterestGroup.schema, "id"))
            .field("venue_id", .uuid, .required, .references(Venue.schema, "id"))
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Event.schema)
            .delete()
    }
}
