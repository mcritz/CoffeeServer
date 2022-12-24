import Plot

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
