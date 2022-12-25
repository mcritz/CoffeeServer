import Plot
import Foundation

struct EventSummaryView: Component {
    let event: EventData
    
    private let formatter = DateFormatter()
    
    var body: Component {
        Div {
            Text(event.name)
            Div {
                Text(formatter.string(from: event.startAt))
            }
            if let venue = event.venue {
                Div {
                    Text(venue.name)
                }
            }
        }
    }
}
