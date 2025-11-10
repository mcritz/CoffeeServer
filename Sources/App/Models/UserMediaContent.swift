//
//  UserMediaContent.swift
//  CoffeeServer
//
//  Created by Michael Critz on 11/9/25.
//

import Fluent
import Vapor

final class UserMediaContent: Model {
    static let schema = "user+mediacontent"
    
    @ID(key: .id) var id: UUID?
    
    @Parent(key: "mediacontent_id")
    var mediaContent: MediaContent
    
    @Parent(key: "user_id")
    var user: User
    
    init() { }
    
    init(id: UUID? = nil, user: User, mediaContent: MediaContent) throws {
        self.id = id
        self.$user.id = try user.requireID()
        self.$mediaContent.id = try mediaContent.requireID()
    }
}
