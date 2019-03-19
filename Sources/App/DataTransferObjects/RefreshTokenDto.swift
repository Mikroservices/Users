//
//  RefreshTokenDto.swift
//  App
//
//  Created by Marcin Czachurski on 19/03/2019.
//

import Vapor

final class RefreshTokenDto {

    var refreshToken: String

    init(refreshToken: String) {
        self.refreshToken = refreshToken
    }
}

extension RefreshTokenDto: Content { }
