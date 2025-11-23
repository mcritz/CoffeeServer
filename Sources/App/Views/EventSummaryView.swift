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
            Div {
                Text(event.venue.name)
            }
        }
    }
}
