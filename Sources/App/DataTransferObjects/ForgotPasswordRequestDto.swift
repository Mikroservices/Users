//
//  ForgotPasswordRequestDto.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 12/11/2018.
//

import Vapor

/// Class for forgot password process.
final class ForgotPasswordRequestDto {

    var email: String

    init(email: String) {
        self.email = email
    }
}


/// Allows `ForgotPasswordRequestDto` to be encoded to and decoded from HTTP messages.
extension ForgotPasswordRequestDto: Content { }
