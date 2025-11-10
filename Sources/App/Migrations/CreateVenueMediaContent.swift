//
//  CreateVenueMediaContent.swift
//  CoffeeServer
//
//  Created by Michael Critz on 11/9/25.
//

import Fluent
import Vapor

struct CreateVenueMediaContent: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(VenueMediaContent.schema)
            .id()
            .field("venue_id", .uuid, .required, .references(Venue.schema, "id"))
            .field("mediacontent_id", .uuid, .required, .references(MediaContent.schema, "id"))
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(VenueMediaContent.schema).delete()
    }
}

