//
//  SignInRequestDto.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 25/10/2018.
//

import Vapor

final class LoginRequestDto {

    var userNameOrEmail: String
    var password: String

    init(userNameOrEmail: String, password: String) {
        self.userNameOrEmail = userNameOrEmail
        self.password = password
    }
}

extension LoginRequestDto: Content { }
