//
//  UpdateInteresteGroupAddSlug.swift
//  CoffeeServer
//
//  Created by Michael Critz on 11/30/25.
//

import Fluent

struct UpdateInteresteGroupAddSlug: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(InterestGroup.schema)
            .field("short", .string)
            .update()
        
        let allGroups = try await InterestGroup.query(on: database).all()

        for iGroup in allGroups {
            let newSlug = iGroup.$short.wrappedValue.lowercased()
                .replacingOccurrences(of: " ", with: "-")
            iGroup.short = newSlug
            try await iGroup.save(on: database)
        }
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(InterestGroup.schema)
            .deleteField("short")
            .update()
    }
}
