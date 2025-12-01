//
//  UpdateInteresteGroupAddSlug.swift
//  CoffeeServer
//
//  Created by Michael Critz on 11/30/25.
//

import Fluent

struct UpdateInteresteGroupAddShort: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(InterestGroup.schema)
            .field("short", .string)
            .unique(on: "short")
            .update()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(InterestGroup.schema)
            .deleteField("short")
            .update()
    }
}
