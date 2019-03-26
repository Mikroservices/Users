//
//  Setting.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 18/03/2019.
//

import FluentPostgreSQL
import Vapor

/// A single entry of a Setting list.
final class Setting: PostgreSQLUUIDModel {

    var id: UUID?
    var key: String
    var value: String

    init(id: UUID? = nil,
         key: String,
         value: String
    ) {
        self.id = id
        self.key = key
        self.value = value
    }
}

/// Allows `Setting` to be used as a dynamic migration.
extension Setting: Migration { }

/// Allows `Setting` to be encoded to and decoded from HTTP messages.
extension Setting: Content { }

/// Allows `Setting` to be used as a dynamic parameter in route definitions.
extension Setting: Parameter { }
