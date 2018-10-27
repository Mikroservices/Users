//
//  User.swift
//  App
//
//  Created by Marcin Czachurski on 08/10/2018.
//

import FluentSQLite
import Vapor

/// A single entry of a Voice list.
final class User: SQLiteModel {

    var id: Int?
    var email: String
    var userName: String
    var password: String

    init(id: Int? = nil, email: String, userName: String, password: String) {
        self.id = id
        self.email = email
        self.userName = userName
        self.password = password
    }
}

/// Allows `Voice` to be used as a dynamic migration.
extension User: Migration { }

/// Allows `Voice` to be encoded to and decoded from HTTP messages.
extension User: Content { }

/// Allows `Voice` to be used as a dynamic parameter in route definitions.
extension User: Parameter { }
