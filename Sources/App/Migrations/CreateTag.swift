import Fluent

extension Tag {
    struct Migration: AsyncMigration {
        var name: String { "CreateTag" }

        func prepare(on database: Database) async throws {
            try await database.schema(Tag.schema)
                .id()
                .field("name", .string, .required)
                .unique(on: "name")
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema(Tag.schema).delete()
        }
    }
}
