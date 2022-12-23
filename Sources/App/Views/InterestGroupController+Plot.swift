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
        async let groupEvents: [InterestGroup : [EventData]] = withThrowingTaskGroup(of: [InterestGroup : [EventData]].self) { taskGroup in
            for interestGroup in allGroups {
                taskGroup.addTask {
                    let eventModels = try await interestGroup.$events.get(on: req.db)
                    var eventDatas = [EventData]()
                    for eventModel in eventModels {
                        let venue = try await eventModel.$venue.get(on: req.db)
                        var eventData = eventModel.publicData()
                        eventData.venue = venue
                        eventDatas.append(eventData)
                    }
                    eventDatas.sort { $0.startAt < $1.startAt }
                    return [interestGroup : eventDatas]
                }
            }
            var allResults = [InterestGroup: [EventData]]()
            for try await childResult in taskGroup {
                for key in childResult.keys {
                    allResults[key] = childResult[key]
                }
            }
            return allResults
        }
        
        let sortedGroupEvents = try await groupEvents.sorted(by: { lhs, rhs in
            lhs.0.name < rhs.0.name
        })
        
        let list = Node.body(
            .h1("Coffee!"),
            .h2("Groups"),
            .ul(.forEach(sortedGroupEvents) { group, events in
                .li(.class("group-name"), .div(
                    .text(group.name),
                    .a(.href("/groups/\(group.id!.uuidString)/calendar"),
                       "Subscribe to Calendar"
                      ),
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
                                ),
                                .div(
                                    .text(event.venue?.name ?? "No Venue")
                                ),
                                .div(
                                    .text("\(event.venue?.location.latitude ?? 0.0)"),
                                    .text("\(event.venue?.location.longitude ?? 0.0)")
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
