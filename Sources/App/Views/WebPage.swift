import Plot
import Vapor

fileprivate extension HTTPHeaders {
    static let defaultHeaders = HTTPHeaders(dictionaryLiteral: ("Content-Type", "text/html"))
}

struct WebPage {
    init(body: Component) {
        self.body = body
    }
    
    public func response(status: HTTPResponseStatus = .ok, headers: HTTPHeaders = .defaultHeaders) -> Response {
        let body = HTML(
            .head(
                .title("The Coffee"),
                .stylesheet("/style.css")
            ),
            .body(buildBody)
        )
            .render()
        let resposneHeaders: HTTPHeaders = HTTPHeaders(dictionaryLiteral:
            ("Content-Type", "text/html"),
            ("ETag", "bean_\(body.hashValue)")
        )
        return Response(status: status, headers: resposneHeaders, body: .init(string: body))
    }
    
    private let body: Component
    
    private func buildBody() -> Component {
        self.body.class("dark")
    }
}
