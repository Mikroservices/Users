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

        let settingsService = try request.make(SettingsService.self)
        let usersService = try request.make(UsersService.self)
        let emailsService = try request.make(EmailsService.self)

        let updateUserFuture = try usersService.forgotPassword(on: request, email: forgotPasswordRequestDto.email)
        let configurationFuture = try settingsService.get(on: request)

        return map(to: Void.self, updateUserFuture, configurationFuture) { user, configuration in
            _ = try emailsService.sendForgotPasswordEmail(on: request, configuration: configuration, user: user)
        }.transform(to: HTTPStatus.ok)
    }

    /// Changing password.
    func forgotPasswordConfirm(request: Request, confirmationDto: ForgotPasswordConfirmationRequestDto) throws -> Future<HTTPResponseStatus> {

        try confirmationDto.validate()

        let usersService = try request.make(UsersService.self)
        return try usersService.confirmForgotPassword(
            on: request,
            forgotPasswordGuid: confirmationDto.forgotPasswordGuid,
            password: confirmationDto.password
        ).transform(to: HTTPStatus.ok)
    }
}
