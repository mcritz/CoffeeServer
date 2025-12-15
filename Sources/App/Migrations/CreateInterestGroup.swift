import Fluent

struct CreateInterestGroup: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(InterestGroup.schema)
            .id()
            .field("name", .string, .required)
            .field("short", .string, .required)
            .unique(on: "short")
            .field("image_url", .string)
            .field("archived", .bool)
            .unique(on: "name")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(InterestGroup.schema).delete()
    }
}

