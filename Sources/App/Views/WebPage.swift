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
        let body = HTML(body: buildBody).render()
        return Response(status: status, headers: headers, body: .init(string: body))
    }
    
    private let body: Component
    
    private func buildBody() -> Component {
        self.body
    }
}
