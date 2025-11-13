//
//  VenueMediaContent.swift
//  CoffeeServer
//
//  Created by Michael Critz on 11/9/25.
//

import Fluent
import Vapor

final class VenueMediaContent: Model, @unchecked Sendable {
    static let schema = "venue+mediacontent"
    
    @ID(key: .id) var id: UUID?
    
    @Parent(key: "venue_id") var venue: Venue
    
    @Parent(key: "mediacontent_id") var mediaContent: MediaContent
    
    init() { }
}
