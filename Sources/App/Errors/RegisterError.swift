//
//  RegisterError.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 14/11/2018.
//

import Vapor
import ExtendedError

enum RegisterError: String, Error {
    case securityTokenIsMandatory
    case passwordIsRequired
    case securityTokenIsInvalid
    case userWithEmailExists
    case userIdNotExists
    case invalidIdOrToken
}

extension RegisterError: TerminateError {
    var status: HTTPResponseStatus {
        return .badRequest
    }

    var reason: String {
        switch self {
        case .securityTokenIsMandatory: return "Security token is mandatory (it should be provided from Google reCaptcha)."
        case .passwordIsRequired: return "Password is required. User have to provide some."
        case .securityTokenIsInvalid: return "Security token is invalid (Google reCaptcha API returned that information)."
        case .userWithEmailExists: return "User with provided email already exists in the system."
        case .userIdNotExists: return "User Id not exists. Probably saving of the user entity failed."
        case .invalidIdOrToken: return "Invalid user Id or token. User have to activate account by reseting his password."
        }
    }

    var identifier: String {
        return "register"
    }

    var code: String {
        return self.rawValue
    }
}
