//
//  ChangePasswordRequestDto.swift
//  App
//
//  Created by Marcin Czachurski on 18/11/2018.
//

import Vapor

final class ChangePasswordRequestDto {

    var currentPassword: String
    var newPassword: String

    init(currentPassword: String, newPassword: String) {
        self.currentPassword = currentPassword
        self.newPassword = newPassword
    }
}

extension ChangePasswordRequestDto: Content { }
