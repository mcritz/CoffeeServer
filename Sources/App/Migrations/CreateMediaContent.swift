//
//  CreateMediaContent.swift
//  CoffeeServer
//
//  Created by Michael Critz on 11/9/25.
//

import Fluent

struct CreateMediaContent: AsyncMigration {
    var name: String = "CreateUserMedia"
    
    func prepare(on db: Database) async throws {
        try await db.schema(MediaContent.schema)
            .id()
            .field("filename", .string, .required)
            .unique(on: "filename")
            .field("raw_filename", .string, .required)
            .field("mime_type", .string, .required)
            .field("content_length", .int, .required)
            .field("user_id", .uuid, .required, .references(User.schema, "id"))
            .field("venue_id", .uuid, .references(Venue.schema, "id"))
            .create()
    }
        
    func revert(on db: Database) async throws {
        try await db.schema(MediaContent.schema).delete()
    }
}
