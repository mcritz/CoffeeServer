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

    var body: Component {
        Div {
            Text(group.name)
            Link("Calendar", url: calendarURLString())
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
        .class("group-view")
    }
}
