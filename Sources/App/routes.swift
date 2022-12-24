import Fluent
import Vapor

func routes(_ app: Application) throws {
    let interestGroupController = InterestGroupController()
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
       
       \(currentDate.formatted())
       \(currentDate)
       """
    }

    try app.register(collection: TodoController())
    try app.register(collection: interestGroupController)
    try app.register(collection: UserController())
    try app.register(collection: TagController())
    try app.register(collection: EventController())
    try app.register(collection: VenueController())
}
