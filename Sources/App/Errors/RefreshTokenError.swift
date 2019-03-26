//
//  RefreshTokenError.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 18/03/2019.
//

import Vapor
import ExtendedError

enum RefreshTokenError: String, Error {
    case userIdNotSpecified
    case refreshTokenNotExists
}

extension RefreshTokenError: TerminateError {
    var status: HTTPResponseStatus {
        return .badRequest
    }

    var reason: String {
        switch self {
        case .refreshTokenNotExists: return "Refresh token not exists or it's expired."
        case .userIdNotSpecified: return "User id must be specified for refresh token."
        }
    }

    var identifier: String {
        return "refresh"
    }

    var code: String {
        return self.rawValue
    }
}
