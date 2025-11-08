import Fluent

struct CreateVenue: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Venue.schema)
            .id()
            .field("name", .string, .required)
            .field("location", .json)
            .field("url", .json)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Venue.schema)
            .delete()
    }
}
