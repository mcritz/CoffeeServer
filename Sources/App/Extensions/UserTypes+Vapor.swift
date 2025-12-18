import CoffeeKit
import Vapor

extension UserCreate: @retroactive RequestDecodable {}
extension UserCreate: @retroactive ResponseEncodable {}
extension UserCreate: @retroactive AsyncRequestDecodable {}
extension UserCreate: @retroactive AsyncResponseEncodable {}
extension UserCreate: @retroactive Content { }

extension UserPublic: @retroactive RequestDecodable {}
extension UserPublic: @retroactive ResponseEncodable {}
extension UserPublic: @retroactive AsyncRequestDecodable {}
extension UserPublic: @retroactive AsyncResponseEncodable {}
extension UserPublic: @retroactive Content { }

extension UserPrivate: @retroactive RequestDecodable {}
extension UserPrivate: @retroactive ResponseEncodable {}
extension UserPrivate: @retroactive AsyncRequestDecodable {}
extension UserPrivate: @retroactive AsyncResponseEncodable {}
extension UserPrivate: @retroactive Content { }
