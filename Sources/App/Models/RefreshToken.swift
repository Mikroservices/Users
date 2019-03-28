import FluentPostgreSQL
import Vapor
import Crypto

/// A single entry of a Voice list.
final class RefreshToken: PostgreSQLUUIDModel {

    var id: UUID?
    var userId: UUID
    var token: String
    var expiryDate: Date
    var revoked: Bool = false

    init(id: UUID? = nil,
         userId: UUID,
         token: String,
         expiryDate: Date,
         revoked: Bool = false
    ) {
        self.id = id
        self.userId = userId
        self.token = token
        self.expiryDate = expiryDate
        self.revoked = revoked
    }
}

/// User which generate refresh token.
extension RefreshToken {
    var user: Parent<RefreshToken, User> {
        return parent(\.userId)
    }
}

/// Allows `RefreshToken` to be used as a dynamic migration.
extension RefreshToken: Migration { }

/// Allows `RefreshToken` to be encoded to and decoded from HTTP messages.
extension RefreshToken: Content { }

/// Allows `RefreshToken` to be used as a dynamic parameter in route definitions.
extension RefreshToken: Parameter { }
