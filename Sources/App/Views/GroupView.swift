import Plot
import Vapor

struct GroupView: Component {
    let group: InterestGroup
    let events: [EventData]

    private func backgroundImageURL(event: EventData) -> ImageURL {
        guard let imageURL = event.imageURL else {
            return "default-coffee.webp"
        }
        return imageURL
    }

    private func backgroundImageURL(group: InterestGroup) -> String {
        guard let groupImageURL = group.imageURL else {
            return "default-coffee.webp"
        }
        return groupImageURL
    }

    var body: Component {
        guard let groupURL = try? group.requireID() else {
            // Nothing to see...
            return Div().class("hidden")
        }
        let upcoming = events.filter { $0.endAt >= Date.now }
        if let nextEvent = upcoming.first {
            return Div {
                Link(url: "/groups/\(groupURL)") {
                    H2(group.name)
                    Div {
                        H3(nextEvent.name)
                        Paragraph(
                            nextEvent.startAt
                                .formatted(date: .numeric,
                                           time: .shortened)
                        )
                    }
                    .class("bar")
                }
                .class("event")
                .style(
                    """
                    background-image: 
                        linear-gradient(
                        0deg, 
                        rgba(2,0,36,0.5) 0%, rgba(1, 0, 18, 0.0) 75%), 
                        url('\(backgroundImageURL(event: nextEvent))');
                    background-size: cover;
                    """
                )
            }
            .class("coffee-group")
        } else {
            return Div {
                Link(url: "/groups/\(groupURL)") {
                    H2(group.name)
                    Div {
                        if events.count > 0 {
                            H3("\(events.count) events")
                        } else {
                            H3("No events, yet!")
                        }
                    }
                    .class("bar")
                }
                .class("event")
                .style(
                    """
                    background-image: 
                        linear-gradient(
                            0deg, 
                            rgba(2,0,36,0.5) 0%, 
                            rgba(1, 0, 18, 0.0) 75%), 
                        url('\(backgroundImageURL(group: group))');
                    background-size: cover;
                    """
                )
            }
            .class("coffee-group")
        }
    }
}
