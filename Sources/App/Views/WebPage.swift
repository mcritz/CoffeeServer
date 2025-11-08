import Plot
import Vapor

struct WebPage {
    private let content: Component
    
    init(_ content: Component) {
        self.content = Node.body { content }
    }
    
    public func response(status: HTTPResponseStatus = .ok, headers: HTTPHeaders = .defaultHeaders) -> Response {
        let body = HTML(
            .head(
                .encoding(.utf8),
                .title("CoffeeCoffeeCoffee.coffee"),
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
    
    
    private func buildBody() -> Component {
        self.content
    }
}
