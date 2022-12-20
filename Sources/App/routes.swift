import Foundation.NSDate
import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        WebPage(body: home).response()
    }

    app.get("healthcheck") { req async -> String in
        let currentDate = Date()
        return """
       OK.
       \(currentDate.formatted())
       \(currentDate)
       """
    }

    try app.register(collection: TodoController())
    try app.register(collection: InterestGroupController())
    try app.register(collection: UserController())
    try app.register(collection: TagController())
}
