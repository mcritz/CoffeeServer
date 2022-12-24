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
                .li(.class("group-name"),
                    GroupView(group: group, events: events).convertToNode()
                )
            })
        )
        return WebPage(body: list).response()
    }
}


struct GroupView: Component {
    let group: InterestGroup
    let events: [EventData]

    var body: Component {
        Div {
            Text(group.name)
            Link("Subscribe to Calendar", url: "/groups/\(group.id!.uuidString)/calendar")
            if(events.count < 1) {
                List {
                    ListItem {
                        Text("No Events")
                    }
                }.listStyle(.unordered)
            } else {
                List {
                    for event in events {
                        ListItem {
                            EventSummaryView(event: event)
                        }.class("event-name")
                    }
                }.listStyle(.unordered)
            }
        }
    }
}

struct EventSummaryView: Component {
    let event: EventData
    
    var body: Component {
        Div {
            Text(event.name)
            Div {
                Text(event.startAt.formatted())
            }
            if let venue = event.venue {
                Div {
                    Text(venue.name)
                }
            }
        }
    }
}
