import Fluent
import Plot
import Vapor

extension InterestGroup: Hashable, Equatable {
    static func == (lhs: InterestGroup, rhs: InterestGroup) -> Bool {
        lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        self.name.hash(into: &hasher)
    }
}

// MARK: - WebView
extension InterestGroupController {
    func webView(req: Request) async throws -> Response {
        let allGroups = try await InterestGroup.query(on: req.db).all()
        async let groupEvents: [InterestGroup : [EventData]] = withThrowingTaskGroup(of: (InterestGroup, [EventData]).self) { taskGroup in
            for interestGroup in allGroups {
                taskGroup.addTask {
                    let events = try await interestGroup.$events.get(on: req.db)
                    let eventDatas = events.map { $0.publicData() }
                    return (interestGroup, eventDatas)
                }
            }
            var childResults = [InterestGroup: [EventData]]()
            for try await childResult in taskGroup {
                childResults[childResult.0] = childResult.1
            }
            return childResults
        }
        
        let list = try await Node.body(
            .h2("Groups"),
            .ul(.forEach(groupEvents) { group, events in
                .li(.class("group-name"), .div(
                    .text(group.name),
                    .if(events.count < 1,
                        .ul(.li(.text("No Events")))
                    ),
                    .if(events.count > 0,
                        .ul(.forEach(events) { event in
                            .li(.class("event-name"),
                                .div(
                                    .text(event.name)
                                ),
                                .div(
                                    .text(event.startAt.formatted())
                                )
                            )
                        })
                    )
                ))
            })
        )
        return WebPage(body: list).response()
    }
}
