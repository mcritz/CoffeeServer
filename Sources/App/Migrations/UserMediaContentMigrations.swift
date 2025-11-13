//
//  UserMediaContentMigrations.swift
//  CoffeeServer
//
//  Created by Michael Critz on 11/9/25.
//

import Fluent
import Vapor

extension UserMediaContent {
    struct Migration: AsyncMigration {
        var name: String = "CreateUserMediaContent"
        
        func prepare(on database: any Database) async throws {
            try await database.schema(UserMediaContent.schema)
                .id()
                .field("user_id", .uuid, .required, .references(User.schema, "id"))
                .field("mediacontent_id", .uuid, .required, .references(MediaContent.schema, "id"))
                .create()
        }
        
        func revert(on db: Database) async throws {
            try await db.schema(UserMediaContent.schema).delete()
        }
    }
}
