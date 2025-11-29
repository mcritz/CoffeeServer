import Plot
import Foundation

struct EventSummaryView: Component {
    let event: EventData
    
    private let formatter = DateFormatter()
    
    var body: Component {
        Div {
            Div {
                Text(formatter.string(from: event.startAt))
            }
            Text(event.name)
            Div {
                Text(event.venue.name)
            }
        }
    }
}
