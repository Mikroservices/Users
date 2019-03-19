//
//  AccessTokenDto.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 25/10/2018.
//

import Vapor

final class AccessTokenDto {

    var accessToken: String
    var refreshToken: String

    init(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}

extension AccessTokenDto: Content { }
