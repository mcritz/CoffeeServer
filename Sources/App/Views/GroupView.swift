import Plot

struct GroupView: Component {
    let group: InterestGroup
    let events: [EventData]

    var body: Component {
        Div {
            Text(group.name)
            Link("Subscribe to Calendar", url: "/groups/\(group.id!.uuidString)/calendar.ics")
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
