import Plot
import Vapor

struct GroupView: Component {
    let hostURL: String
    let group: InterestGroup
    let events: [EventData]

    private func backgroundImageURL(event: EventData) -> String {
        guard let imageURL = event.imageURL else {
            return "TODO DEFAULT IMAGE URL"
        }
        return imageURL.absoluteString
    }

    var body: Component {
        if let groupURL = try? group.requireID(),
            let nextEvent = events.first {
            return Div {
                Link(url: "/groups/\(groupURL)") {
                    H2(group.name)
                    Div {
                        H3(nextEvent.name)
                        // TODO: We should have a client side solution for this (though it works for now)
                        H4(nextEvent.startAt.formatted(date: .numeric, time: .complete))
                    }
                    .class("bar")
                }
                .class("event")
                .style("""
                        background-image: 
                            linear-gradient(0deg, rgba(2,0,36,0.5) 0%, rgba(1, 0, 18, 0.0) 75%), 
                            url('\(backgroundImageURL(event: nextEvent))');
                """)
            }
            .class("coffee-group")
        } else {
            // Nothing to show...
            return Div()
        }
    }
}
