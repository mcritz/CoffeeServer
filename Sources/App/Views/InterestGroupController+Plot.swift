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
    
    public func interestGroupsAndEvents(req: Request) async throws -> [(InterestGroup, [EventData])] {
        let allGroups = try await InterestGroup.query(on: req.db).all()
        let groupEvents: [(InterestGroup, [EventData])] = try await withThrowingTaskGroup(of: [(InterestGroup, [EventData])].self) { taskGroup in
            var rawGroupsAndEvents = [(InterestGroup, [EventData])]()
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
                    return [(interestGroup, eventDatas)]
                }
            }
            for try await element in taskGroup {
                rawGroupsAndEvents.append(contentsOf: element)
            }
            let sortedGroupEvents = rawGroupsAndEvents.sorted { alpha, bravo in
                guard let alphaMostRecentEvent = alpha.1.first?.endAt,
                      let bravoMostRecentEvent = bravo.1.first?.endAt else { return false }
                return alphaMostRecentEvent < bravoMostRecentEvent
            }
            return sortedGroupEvents
        }
        
        let sortedGroupEvents =  groupEvents.sorted(by: { lhs, rhs in
            lhs.0.name < rhs.0.name
        })
        return sortedGroupEvents
    }
    
    func webView(req: Request) async throws -> Response {
        let sortedGroupEvents = try await interestGroupsAndEvents(req: req)
        guard sortedGroupEvents.count > 0 else {
            return WebPage(NoGroupsView()).response()
        }
        let list = Div {
                H1("Coffee!")
                List(sortedGroupEvents) { group, events in
                    ListItem {
                        GroupView(hostURL: hostURL, group: group, events: events)
                    }
                    .class("group-view-wrapper")
                }
                .class("group-ul")
            }
            .class("wrapper")
        return WebPage(list).response()
    }
}
