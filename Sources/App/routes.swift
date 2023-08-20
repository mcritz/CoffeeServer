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
    
//    app.get("render") { req async throws -> Response in
//        req.logger.info("render start")
//        print("render a")
//        let host = req.application.http.server.configuration.hostname
//        let port = req.application.http.server.configuration.port
////        let allGetRoutes = app.routes.all.filter { route in
////            return route.method == .GET
////        }
//
//
//        for group in try await InterestGroup.query(on: req.db).all() {
//            do {
//                let groupURI = try URI(scheme: .http, host: host, port: port, path: "/groups/\(group.requireID())/events")
//                let response = try await app.client.get(groupURI)
//                guard let responseBody = response.body else {
//                    let errorMessage = "No response for \(groupURI)"
//                    req.logger.warning(.init(stringLiteral: errorMessage))
//                    throw Abort.init(.imATeapot, reason: errorMessage)
//                }
//                let filePath = try group.requireID().uuidString
//                try writeToDisk(responseBody, path: filePath)
//                req.logger.info(.init(stringLiteral: "Wrote \(group.name) to \(filePath)"))
//                print("Wrote \(group.name) to \(filePath)")
//            } catch {
//                throw Abort(.internalServerError, reason: error.localizedDescription)
//            }
//        }
//
////        for try route in allGetRoutes {
////            let routePath: String = route.path.map { pathComponent in
////                pathComponent.description
////            }
////            .reduce("") { partialResult, thisItem in
////                return partialResult + "/" + thisItem
////            }
////            let routeURI = URI(scheme: .http, host: host, port: port, path: routePath, query: nil, fragment: nil)
////            Task {
////                app.logger.info("fetching \(routePath)")
////                let response = try await app.client.get(routeURI)
////                guard let responseBody = response.body else {
////                    let errorMessage = "No response for \(routeURI)"
////                    req.logger.warning(.init(stringLiteral: errorMessage))
////                    throw Abort.init(.imATeapot, reason: errorMessage)
////                }
////                let wroteString = try writeToDisk(responseBody, path: routePath)
////                print("wrote: \(wroteString.count)")
////            }
////        }
//        req.logger.info("render end")
//        print("render x")
//        return Response(status: .ok,
//                        headers: .defaultHeaders,
//                        body: .init(stringLiteral: "OK"))
//    }
    
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

    try app.register(collection: RenderController())
    try app.register(collection: TodoController())
    try app.register(collection: interestGroupController)
    try app.register(collection: UserController())
    try app.register(collection: TagController())
    try app.register(collection: EventController())
    try app.register(collection: VenueController())
}
