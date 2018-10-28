//
//  UserDto.swift
//  App
//
//  Created by Marcin Czachurski on 08/10/2018.
//

import Vapor

/// A single entry of a Voice list.
final class UserDto {

    var id: UUID?
    var email: String
    var name: String
    var password: String?

    init(id: UUID? = nil, email: String, name: String, password: String?) {
        self.id = id
        self.email = email
        self.name = name
        self.password = password
    }
}

/// Allows `UserDto` to be encoded to and decoded from HTTP messages.
extension UserDto: Content { }
