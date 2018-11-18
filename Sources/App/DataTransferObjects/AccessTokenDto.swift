//
//  AccessTokenDto.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 25/10/2018.
//

import Vapor

final class AccessTokenDto {

    var accessToken: String

    init(_ accessToken: String) {
        self.accessToken = accessToken
    }
}

extension AccessTokenDto: Content { }
