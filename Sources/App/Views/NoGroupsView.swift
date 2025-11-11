import Plot

struct NoGroupsView: Component {
    var body: Component {
        Div {
            Header {
                H1("Coffee Coffee Coffee Coffee")
                    .class("hidden")
                Image("/logo-stack.png")
            }
            H2("Nothing going on")
        }
    }
}
