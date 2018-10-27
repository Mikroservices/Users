//
//  UserDto.swift
//  App
//
//  Created by Marcin Czachurski on 08/10/2018.
//

import Vapor

/// A single entry of a Voice list.
final class UserDto {

    var id: Int?
    var email: String
    var userName: String
    var password: String?

    init(id: Int? = nil, email: String, userName: String, password: String?) {
        self.id = id
        self.email = email
        self.userName = userName
        self.password = password
    }
}

/// Allows `UserDto` to be encoded to and decoded from HTTP messages.
extension UserDto: Content { }
