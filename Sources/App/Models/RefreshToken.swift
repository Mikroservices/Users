//
//  RefreshToken.swift
//  App
//
//  Created by Marcin Czachurski on 18/03/2019.
//

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

/// Allows `RefreshToken` to be used as a dynamic migration.
extension RefreshToken: Migration { }

/// Allows `RefreshToken` to be encoded to and decoded from HTTP messages.
extension RefreshToken: Content { }

/// Allows `RefreshToken` to be used as a dynamic parameter in route definitions.
extension RefreshToken: Parameter { }
