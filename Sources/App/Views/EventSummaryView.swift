import CoffeeKit
import Plot
import Foundation

struct EventSummaryView: Component {
    let event: EventData
    
    var body: Component {
        Div {
            Div {
                Text(event.startAt.formattedWith())
            }
            Text(event.name)
            Div {
                Text(event.venue.name)
            }
        }
    }
}
