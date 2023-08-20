import Fluent
import Vapor

struct RenderController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let renderAPI = routes.grouped("api", "v2", "render")
        renderAPI.get(use: render)
    }
    
    func render(req: Request) async throws -> String {
        req.logger.info("render start")
        print("render a")
        let host = req.application.http.server.configuration.hostname
        let port = req.application.http.server.configuration.port
//        let allGetRoutes = app.routes.all.filter { route in
//            return route.method == .GET
//        }
            
        var statusText = "Rendering…"
        for group in try await InterestGroup.query(on: req.db).all() {
            let groupURI = try URI(scheme: .http, host: host, port: port, path: "api/v2/groups/\(group.requireID())/events")
            let response = try await req.application.client.get(groupURI)
            guard let responseBody = response.body else {
                let errorMessage = "No response for \(groupURI)"
                req.logger.warning(.init(stringLiteral: errorMessage))
                throw Abort.init(.imATeapot, reason: errorMessage)
            }
            let groupID = try group.requireID().uuidString
            let filePath = "group/\(groupID).json"
            var objCisDirectoryBool = ObjCBool(true)
            let groupDirectory = req.application.directory.publicDirectory + "/group"
            if !FileManager.default.fileExists(atPath: groupDirectory, isDirectory: &objCisDirectoryBool) {
                try FileManager.default.createDirectory(atPath: groupDirectory, withIntermediateDirectories: false)
            }
            try writeToDisk(responseBody, req: req, path: filePath)
            statusText = "Wrote \(group.name) to \(filePath)"
            req.logger.info(.init(stringLiteral: statusText))
            print(statusText)
        }
        
//        for try route in allGetRoutes {
//            let routePath: String = route.path.map { pathComponent in
//                pathComponent.description
//            }
//            .reduce("") { partialResult, thisItem in
//                return partialResult + "/" + thisItem
//            }
//            let routeURI = URI(scheme: .http, host: host, port: port, path: routePath, query: nil, fragment: nil)
//            Task {
//                app.logger.info("fetching \(routePath)")
//                let response = try await app.client.get(routeURI)
//                guard let responseBody = response.body else {
//                    let errorMessage = "No response for \(routeURI)"
//                    req.logger.warning(.init(stringLiteral: errorMessage))
//                    throw Abort.init(.imATeapot, reason: errorMessage)
//                }
//                let wroteString = try writeToDisk(responseBody, path: routePath)
//                print("wrote: \(wroteString.count)")
//            }
//        }
        req.logger.info("render end")
        print("render x")
        return statusText
    }
    
    @discardableResult
    @Sendable func writeToDisk(_ buffer: ByteBuffer, req: Request, path: String) throws -> String {
        let publicDirectory = req.application.directory.publicDirectory
        let groupsData = Data(buffer: buffer, byteTransferStrategy: .automatic)
        let dataString = String(data: groupsData, encoding: .utf8) ?? "No String"
        let groupsPath = publicDirectory + path
        try dataString.write(toFile: groupsPath, atomically: true, encoding: .utf8)
        return dataString
    }
}
