//
//  ForgotPasswordConfirmationRequestDto.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 12/11/2018.
//

import Vapor

/// Class for forgot password confirmation process.
final class ForgotPasswordConfirmationRequestDto: Reflectable {

    var forgotPasswordGuid: String
    var password: String

    init(forgotPasswordGuid: String, password: String) {
        self.forgotPasswordGuid = forgotPasswordGuid
        self.password = password
    }
}

/// Allows `ForgotPasswordConfirmationRequestDto` to be encoded to and decoded from HTTP messages.
extension ForgotPasswordConfirmationRequestDto: Content { }

extension ForgotPasswordConfirmationRequestDto: Validatable {

    /// See `Validatable`.
    static func validations() throws -> Validations<ForgotPasswordConfirmationRequestDto> {
        var validations = Validations(ForgotPasswordConfirmationRequestDto.self)

        try validations.add(\.password, .count(8...32) && .password)

        return validations
    }
}
