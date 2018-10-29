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
    var bio: String?
    var location: String?
    var website: String?
    var birthDate: Date?

    init(id: UUID? = nil,
         email: String,
         name: String,
         password: String?,
         bio: String? = nil,
         location: String? = nil,
         website: String? = nil,
         birthDate: Date? = nil
    ) {
        self.id = id
        self.email = email
        self.name = name
        self.password = password
        self.bio = bio
        self.location = location
        self.website = website
        self.birthDate = birthDate
    }
}

/// Allows `UserDto` to be encoded to and decoded from HTTP messages.
extension UserDto: Content { }
