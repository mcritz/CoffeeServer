//
//  Request+extensions.swift
//  CoffeeServer
//
//  Created by Michael Critz on 11/15/25.
//

import Vapor

extension Request {
    func headerHostName() -> String? {
        self.headers.first(name: "Host")
    }
}
