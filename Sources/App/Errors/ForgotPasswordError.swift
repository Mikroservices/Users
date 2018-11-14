//
//  ForgotPasswordError.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 14/11/2018.
//

import Vapor
import ExtendedError

enum ForgotPasswordError: String, Error {
    case userNotExists
    case userAccountIsBlocked
    case tokenNotGenerated
    case tokenExpired
}

extension ForgotPasswordError: TerminateError {
    var status: HTTPResponseStatus {
        return .badRequest
    }

    var reason: String {
        switch self {
        case .userNotExists: return "User with given email not exists."
        case .userAccountIsBlocked: return "User account is blocked. You cannot change password right now."
        case .tokenNotGenerated: return "Forgot password token wasn't generated. It's really strange."
        case .tokenExpired: return "Token which allows to change password expired. User have to repeat forgot password process."
        }
    }

    var identifier: String {
        return "forgotPassword"
    }

    var code: String {
        return self.rawValue
    }
}
