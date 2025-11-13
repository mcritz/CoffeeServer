import Fluent
import Vapor

final class User: Model, Content, @unchecked Sendable {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "email")
    var email: String

    @Field(key: "password_hash")
    var passwordHash: String
    
    @Siblings(through: UserTag.self, from: \.$user, to: \.$tag)
    public var tags: [Tag]
    
    init() { }

    init(id: UUID? = nil, name: String, email: String, passwordHash: String) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
    }
}

extension User {
    struct Create: Content {
        var name: String
        var email: String
        var password: String
        var confirmPassword: String
    }
    
    struct Public: Content {
        var id: UUID? = nil
        var name: String
    }
    
    struct Private: Content {
        var id: UUID?
        var name: String
        var email: String
    }
    
    func publicValue() -> User.Public {
        .init(id: self.id, name: self.name)
    }
    
    func privateValue() -> User.Private {
        .init(id: self.id, name: self.name, email: self.email)
    }
}

extension User: Authenticatable { }

extension User.Create: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty)
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(8...))
    }
}
