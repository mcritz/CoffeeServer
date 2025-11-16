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
        let now = Calendar(identifier: .gregorian).startOfDay(for: Date())
        let allGroups = try await InterestGroup.query(on: req.db).all()
        let groupEvents: [(InterestGroup, [EventData])] = try await withThrowingTaskGroup(
            of: [(InterestGroup, [EventData])].self
        ) { taskGroup in
            var rawGroupsAndEvents = [(InterestGroup, [EventData])]()
            for interestGroup in allGroups {
                taskGroup.addTask {
                    let eventModels = try await interestGroup
                        .$events
                        .query(on: req.db)
                        .filter(\Event.$endAt >= now)
                        .filter(\Event.$venue.$id != nil)
                        .sort(\.$startAt)
                        .all()
                    // TODO: Update this to one query. It can be done!
                    var eventDatas = [EventData]()
                    for eventModel in eventModels {
                        let venue = try await eventModel.$venue.get(on: req.db)
                        var eventData = eventModel.publicData()
                        eventData.venue = venue
                        eventDatas.append(eventData)
                    }
                    // TODO: Confirm this is unneeded
//                    eventDatas.sort { $0.startAt < $1.startAt }
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
            Header {
                H1("Coffee Coffee Coffee Coffee")
                    .class("hidden")
                Image("/logo-stack.png")
                    .class("header-image")
            }
            Div {
                for (group, events) in sortedGroupEvents {
                    GroupView(group: group, events: events)
                }
            }
            .id("coffee-groups")
        }
        .class("wrapper")
        return WebPage(list).response()
    }
    
    
    private func calendarURLString(_ hostName: String, groupID: UUID) -> String {
        return "webcal://\(hostName)/groups/\(groupID.uuidString)/calendar.ics"
    }
    
    func webViewSingle(req: Request) async throws -> Response {
        let now = Date.now
        let group = try await fetch(req: req)
        let futureEvents = try await group.$events
            .query(on: req.db)
            .filter(\.$endAt > now)
            .filter(\.$venue.$id != nil)
            .with(\.$venue)
            .all()
        // TODO: We should fetch Venues. Which I suppose are actually siblings here.
        
        let content = Div {
            Header {
                Link(url: "/") {
                    Image(url: "/logo-long.png", description: "Home")
                        .class("header-image")
                }
                
                H1(group.name)
                if let groupID = try? group.requireID(),
                   let hostName = req.headerHostName() {
                    Link(url: calendarURLString(hostName, groupID: groupID)) {
                        Image("/icon-calendar.png")
                        Text("Subscribe to Calendar")
                    }
                    .class("white-button")
                }
            }
            if futureEvents.count > 0 {
                Div {
                    H2("Upcoming")
                    for event in futureEvents {
                        coffeeEventView(event)
                    }
                }.id("coffee-groups")
            } else {
                Div {
                    H2("No coffee events scheduled")
                }.id("coffee-groups")
            }
        }
        
        return WebPage(content).response()
    }
    
    private func location(for event: Event) -> String {
        guard let venue = event.venue else {
            return "#"
        }
        if let mapsURL = venue.url {
            return mapsURL
        } else if let location = venue.location,
                  let lat = location.latitude,
                  let lon = location.longitude {
            return "maps://maps.apple.com/?q=\(venue.name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? venue.name)&coordinate=\(lat),\(lon)"
        } else {
            return "#"
        }
    }

    func coffeeEventView(_ event: Event) -> any Component {
        Div {
            Link(url: location(for: event), label: {
                Div {
                    H2(event.name)
                    Div {
                        Div {
                            H4(event.venue?.name ?? "Ask Organizer")
                            if let locationDescription = event.venue?.location?.description {
                                Div {
                                    Span(locationDescription)
                                    Span("Open in Maps")
                                }
                                .class("location-description")
                            }
                            Paragraph(
                                event.startAt
                                    .formatted(date: .abbreviated, time: .shortened)
                            )
                        }.class("details")
                    }.class("bar")
                }.class("event")
                    .style("""
                    background-image: linear-gradient(
                        0deg, 
                        rgba(2,0,36,0.5) 0%, 
                        rgba(1, 0, 18, 0.0) 75%),
                    url('/\(event.imageURL ?? "default-coffee.webp")');
                    background-size: cover;
                """)
            })
        }.class("coffee-group")
    }
}
