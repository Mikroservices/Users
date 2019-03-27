//
//  RegisterUserDto.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 27/03/2019.
//

import Vapor

final class RegisterUserDto: Reflectable {

    var userName: String
    var email: String?
    var name: String?
    var password: String?
    var bio: String?
    var location: String?
    var website: String?
    var birthDate: Date?
    var gravatarHash: String?
    var securityToken: String?

    init(userName: String,
         email: String?,
         gravatarHash: String? = nil,
         name: String? = nil,
         password: String? = nil,
         bio: String? = nil,
         location: String? = nil,
         website: String? = nil,
         birthDate: Date? = nil,
         securityToken: String? = nil
    ) {
        self.userName = userName
        self.email = email
        self.gravatarHash = gravatarHash
        self.name = name
        self.bio = bio
        self.location = location
        self.website = website
        self.birthDate = birthDate
        self.password = password
        self.securityToken = securityToken
    }
}

extension RegisterUserDto: Content { }

extension RegisterUserDto: Validatable {

    /// See `Validatable`.
    static func validations() throws -> Validations<RegisterUserDto> {
        var validations = Validations(RegisterUserDto.self)

        try validations.add(\.userName, .count(1...50) && .alphanumeric)
        try validations.add(\.email, .email && !.nil)
        try validations.add(\.password, .count(8...32) && .password && !.nil)

        try validations.add(\.name, .count(...50) || .nil)
        try validations.add(\.location, .count(...50) || .nil)
        try validations.add(\.website, .count(...50) || .nil)
        try validations.add(\.bio, .count(...200) || .nil)

        try validations.add(\.securityToken, !.nil)

        return validations
    }
}
