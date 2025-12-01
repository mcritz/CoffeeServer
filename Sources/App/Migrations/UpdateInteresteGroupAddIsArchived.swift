//
//  UpdateInteresteGroupAddIsArchived.swift
//  CoffeeServer
//
//  Created by Michael Critz on 11/30/25.
//

import Fluent

struct UpdateInteresteGroupAddIsArchived: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(InterestGroup.schema)
            .field("archived", .bool)
            .update()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(InterestGroup.schema)
            .deleteField("archived")
            .update()
    }
}
