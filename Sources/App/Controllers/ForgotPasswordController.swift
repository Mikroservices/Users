//
//  ForgotPasswordController.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 25/10/2018.
//

import Foundation
import Vapor
import JWT
import Crypto
import Recaptcha
import FluentPostgreSQL

final class ForgotPasswordController: RouteCollection {

    func boot(router: Router) throws {
        router.post(ForgotPasswordRequestDto.self, at: "/forgot/token", use: forgotPasswordToken)
        router.post(ForgotPasswordConfirmationRequestDto.self, at: "/forgot/confirm", use: forgotPasswordConfirm)
    }

    /// Forgot password.
    func forgotPasswordToken(request: Request, forgotPasswordRequestDto: ForgotPasswordRequestDto) throws -> Future<HTTPResponseStatus> {

        let usersService = try request.make(UsersServiceType.self)
        let emailsService = try request.make(EmailsServiceType.self)

        let updateUserFuture = try usersService.forgotPassword(on: request, email: forgotPasswordRequestDto.email)

        let sendEmailFuture = updateUserFuture.map { user in
            try emailsService.sendForgotPasswordEmail(on: request, user: user)
        }

        return sendEmailFuture.transform(to: HTTPStatus.ok)
    }

    /// Changing password.
    func forgotPasswordConfirm(request: Request, confirmationDto: ForgotPasswordConfirmationRequestDto) throws -> Future<HTTPResponseStatus> {

        try confirmationDto.validate()

        let usersService = try request.make(UsersServiceType.self)
        let confirmForgotPasswordFuture = try usersService.confirmForgotPassword(
            on: request,
            forgotPasswordGuid: confirmationDto.forgotPasswordGuid,
            password: confirmationDto.password
        )

        return confirmForgotPasswordFuture.transform(to: HTTPStatus.ok)
    }
}
