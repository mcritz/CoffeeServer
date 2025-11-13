//
//  AddVenueMedia.swift
//  CoffeeServer
//
//  Created by Michael Critz on 11/9/25.
//

import Fluent

struct AddVenueMedia: AsyncMigration {
    func prepare(on database: any FluentKit.Database) async throws {
        try await database.schema(Venue.schema)
            .field("media_id", .uuid, .references(MediaContent.schema, "id"))
            .update()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Venue.schema)
            .deleteField("media_id")
            .update()
    }
}
