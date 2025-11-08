import Plot
import Vapor

struct GroupView: Component {
    let hostURL: String
    let group: InterestGroup
    let events: [EventData]
    
    func calendarURLString() -> String {
        return hostURL
        + "/groups/\(group.id!.uuidString)/calendar.ics"
    }
    //                Link("Calendar", url: calendarURLString())

    var body: Component {
        Div {
            if let groupURL = try? group.requireID() {
                Link(url: "/groups/\(groupURL)") {
                    H2(group.name)
                    if let nextEvent = events.first {
                        Div {
                            H3(nextEvent.name)
                            // FIXME: We need a client side solution for this
                            H4(nextEvent.startAt.formatted(date: .numeric, time: .complete))
                        }
                        .class("bar")
                    }
                }
                .class("event")
            }
        }
        .class("coffee-group")
    }
}
