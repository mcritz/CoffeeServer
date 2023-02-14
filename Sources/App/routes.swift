import Fluent
import Vapor

func routes(_ app: Application) throws {
    let interestGroupController = InterestGroupController(hostURL: hostURL())
    app.get { req async throws in
        try await interestGroupController.webView(req: req)
    }

    app.get("healthcheck") { req async -> String in
        let currentDate = Date()
        let eventCount = try? await Event.query(on: req.db).count()
        let dbHealthText = {
            switch eventCount {
            case .some(let count):
                return "Event count = \(count)"
            default:
                return "DATABASE ERROR"
            }
        }()
        return """
       OK.
       
       Database Check: \(dbHealthText)
       
       \(currentDate)
       """
    }
    
    app.get("render") { req async throws -> String in
        let uri = URI(scheme: .http, host: "127.0.0.1", port: 8080, path: "groups", query: nil, fragment: nil)
        let groupsPage = try await app.client.get(uri)
        guard let pageBody = groupsPage.body else {
            return "No body?"
        }
        let dataString = try writeToDisk(pageBody, path: "/groups")
        return dataString
    }
    
    func hostURL() -> String {
        #if DEBUG
        let uriProtocol = "http://"
        #else
        let uriProtocol = "webcal://"
        #endif
        let hostName = app.http.server
            .configuration.hostname
        let hostPort = app.http.server
            .configuration.port
        return uriProtocol + hostName + ":" + String(hostPort)
    }
    
    func writeToDisk(_ buffer: ByteBuffer, path: String) throws -> String {
        let publicDirectory = app.directory.publicDirectory
        let groupsData = Data(buffer: buffer, byteTransferStrategy: .automatic)
        let dataString = String(data: groupsData, encoding: .utf8) ?? "No String"
        let groupsPath = publicDirectory + path
        try dataString.write(toFile: groupsPath, atomically: true, encoding: .utf8)
        return dataString
    }

    try app.register(collection: TodoController())
    try app.register(collection: interestGroupController)
    try app.register(collection: UserController())
    try app.register(collection: TagController())
    try app.register(collection: EventController())
    try app.register(collection: VenueController())
}
