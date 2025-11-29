//
//  EventData.swift
//  CoffeeServer
//
//  Created by Michael Critz on 11/22/25.
//

import Vapor

struct EventData: Codable {
    var id: UUID?
    var name: String
    var groupID: UUID
    var venue: Venue
    var imageURL: ImageURL?
    var startAt: Date
    var endAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case groupID = "group_id"
        case name
        case imageURL = "image_url"
        case startAt = "start_at"
        case endAt = "end_at"
        case venue
    }
}

extension EventData: Content { }

extension EventData: AsyncResponseEncodable {
    func encodeResponse(for request: Vapor.Request) async throws -> Vapor.Response {
        let body = try JSONEncoder().encode(self)
        let jsonHeader = HTTPHeaders.init(dictionaryLiteral: ("Content-Type", "application/json"))
        return Response(headers: jsonHeader, body: .init(data: body))
    }
}
