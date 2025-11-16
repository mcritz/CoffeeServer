//
//  UpdateEventImageURL.swift
//  CoffeeServer
//
//  Created by Michael Critz on 11/15/25.
//

import Fluent

struct UpdateEventImageURL: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Event.schema)
            .updateField("image_url", .string)
            .update()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(Event.schema)
            .updateField("image_url", .json)
            .update()
    }
}
