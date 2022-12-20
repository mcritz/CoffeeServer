import Fluent
import Plot
import Vapor

// MARK: - WebView
extension InterestGroupController {
    func webView(req: Request) async throws -> Response {
        let allGroups = try await InterestGroup.query(on: req.db).all()
        let list = Node.body(
            .h2("Groups"),
            .ul(.forEach(allGroups) { group in
                .li(.class("group-name"), .text(group.name))
            })
        )
        return WebPage(body: list).response()
    }
}
