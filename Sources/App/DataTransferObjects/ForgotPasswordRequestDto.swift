//
//  ForgotPasswordRequestDto.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 12/11/2018.
//

import Vapor

final class ForgotPasswordRequestDto {

    var email: String

    init(email: String) {
        self.email = email
    }
}

extension ForgotPasswordRequestDto: Content { }
