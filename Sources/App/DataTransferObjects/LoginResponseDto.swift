//
//  SignInResponseDto.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 25/10/2018.
//

import Vapor

final class LoginResponseDto {

    var actionToken: String

    init(_ actionToken: String) {
        self.actionToken = actionToken
    }
}

extension LoginResponseDto: Content { }
