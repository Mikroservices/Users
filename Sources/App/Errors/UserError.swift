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
}

extension UserError: TerminateError {
    var status: HTTPResponseStatus {
        return .badRequest
    }

    var reason: String {
        switch self {
        case .userNotExists: return "User not exists. Probably user Id is incorrect or user deleted his account."
        }
    }

    var identifier: String {
        return "user"
    }

    var code: String {
        return self.rawValue
    }
}
