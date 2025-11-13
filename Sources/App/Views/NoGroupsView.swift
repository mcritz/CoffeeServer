import Plot

struct NoGroupsView: Component {
    var body: Component {
        Div {
            Header {
                H1("Coffee Coffee Coffee Coffee")
                    .class("hidden")
                Image("/logo-stack.png")
                    .class("header-image")
            }
            H2("Nothing going on")
        }
    }
}
