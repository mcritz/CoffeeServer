import CoffeeKit
import Vapor

extension Location: @retroactive Validatable {
    public static func validations(_ validations: inout Vapor.Validations) {
        validations.add("latitude", as: Double.self, is: .range(-90.0...90.0))
        validations.add("longitude", as: Double.self, is: .range(-180.0...180.0))
    }
}

