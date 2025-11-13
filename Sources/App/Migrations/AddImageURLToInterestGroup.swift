//
//  AddImageURLToInterestGroup.swift
//  CoffeeServer
//
//  Created by Michael Critz on 11/11/25.
//

import Fluent

struct AddImageURLToInterestGroup: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(InterestGroup.schema)
            .field("image_url", .string)
            .update()
    }
    
    func revert(on database: Database) {
        database.schema(InterestGroup.schema)
            .deleteField("image_url")
    }
}

