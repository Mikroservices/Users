//
//  User.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 08/10/2018.
//

import FluentPostgreSQL
import Vapor

/// A single entry of a Voice list.
final class User: PostgreSQLUUIDModel {

    var id: UUID?
    var email: String
    var name: String
    var password: String
    var salt: String
    var emailWasConfirmed: Bool
    var isBlocked: Bool
    var emailConfirmationGuid: String
    var bio: String?
    var location: String?
    var website: String?
    var birthDate: Date?

    init(id: UUID? = nil,
         email: String,
         name: String,
         password: String,
         salt: String,
         emailWasConfirmed: Bool,
         isBlocked: Bool,
         emailConfirmationGuid: String,
         bio: String? = nil,
         location: String? = nil,
         website: String? = nil,
         birthDate: Date? = nil
    ) {
        self.id = id
        self.email = email
        self.name = name
        self.password = password
        self.salt = salt
        self.emailWasConfirmed = emailWasConfirmed
        self.isBlocked = isBlocked
        self.emailConfirmationGuid = emailConfirmationGuid
        self.bio = bio
        self.location = location
        self.website = website
        self.birthDate = birthDate
    }
}

/// Allows `Voice` to be used as a dynamic migration.
extension User: Migration { }

/// Allows `Voice` to be encoded to and decoded from HTTP messages.
extension User: Content { }

/// Allows `Voice` to be used as a dynamic parameter in route definitions.
extension User: Parameter { }

extension User {
    convenience init(from userDto: UserDto,
                     withPassword password: String,
                     salt: String,
                     emailConfirmationGuid: String) {
        self.init(
            email: userDto.email,
            name: userDto.name,
            password: password,
            salt: salt,
            emailWasConfirmed: false,
            isBlocked: false,
            emailConfirmationGuid: emailConfirmationGuid,
            bio: userDto.bio,
            location: userDto.location,
            website: userDto.website,
            birthDate: userDto.birthDate
        )
    }
}
