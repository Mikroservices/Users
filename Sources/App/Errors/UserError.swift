//
//  UserError.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 14/11/2018.
//

import Vapor
import ExtendedError

enum UserError: String, Error {
    case userNotExists
    case someoneElseProfile
}

extension UserError: TerminateError {
    var status: HTTPResponseStatus {
        return .badRequest
    }

    var reason: String {
        switch self {
        case .userNotExists: return "User not exists. Probably user Id is incorrect or user deleted his account."
        case .someoneElseProfile: return "User is not a onwer of specified profile. Action is not permitted."
        }
    }

    var identifier: String {
        return "user"
    }

    var code: String {
        return self.rawValue
    }
}
