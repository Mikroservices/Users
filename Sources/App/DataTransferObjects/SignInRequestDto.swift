//
//  SignInRequestDto.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 25/10/2018.
//

import Vapor

/// A single entry of a Voice list.
final class SignInRequestDto {

    var email: String
    var password: String

    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}


/// Allows `UserDto` to be encoded to and decoded from HTTP messages.
extension SignInRequestDto: Content { }
