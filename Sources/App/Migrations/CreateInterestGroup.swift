import Fluent

struct CreateInterestGroup: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(InterestGroup.schema)
            .id()
            .field("name", .string, .required)
            .unique(on: "name")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(InterestGroup.schema).delete()
    }
}

