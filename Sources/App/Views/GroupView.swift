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
        let upcoming = events.filter { $0.endAt >= Date.now }
        if let nextEvent = upcoming.first {
            return Div {
                Link(url: "/\(group.short)") {
                    H2(group.name)
                    Div {
                        H3(nextEvent.name)
                        Paragraph(
                            nextEvent.startAt
                                .formatted(date: .abbreviated,
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
                Link(url: "/\(group.short)") {
                    H2(group.name)
                    Div {
                        if events.count > 0 {
                            H3("\(events.count) events")
                        } else {
                            H3("No events")
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
                            rgba(1, 0, 18, 0.0) 75%, 
                            rgba(1, 0, 18, 0.0) 80%,
                            rgba(32, 0, 16, 0.5) 100%),
                        url('\(backgroundImageURL(group: group))');
                    background-size: cover;
                    """
                )
            }
            .class("coffee-group")
        }
    }
}
