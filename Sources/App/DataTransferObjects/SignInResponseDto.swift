//
//  SignInResponseDto.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 25/10/2018.
//

import Vapor

/// A single entry of a Voice list.
final class SignInResponseDto {

    var actionToken: String

    init(_ actionToken: String) {
        self.actionToken = actionToken
    }
}


/// Allows `SignInResponseDto` to be encoded to and decoded from HTTP messages.
extension SignInResponseDto: Content { }
