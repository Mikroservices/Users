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

        let emailNormalized = forgotPasswordRequestDto.email.uppercased()

        return User.query(on: request).filter(\.emailNormalized == emailNormalized).first().flatMap(to: User.self) { userFromDb in

            guard let user = userFromDb else {
                throw ForgotPasswordError.userNotExists
            }

            if user.isBlocked {
                throw ForgotPasswordError.userAccountIsBlocked
            }

            user.forgotPasswordGuid = UUID.init().uuidString
            user.forgotPasswordDate = Date()

            return user.save(on: request)
        }.flatMap(to: (User, Configuration).self) { user in
            let settingsService = try request.make(SettingsService.self)
            return try settingsService.get(on: request).map(to: (User, Configuration).self) { configuration in
                return (user, configuration)
            }
        }.flatMap(to: Response.self) { (user, configuration) in

            guard let emailServiceAddress = configuration.getString(.emailServiceAddress) else {
                throw Abort(.internalServerError, reason: "Email service is not configured in database.")
            }

            guard let forgotPasswordGuid = user.forgotPasswordGuid else {
                throw ForgotPasswordError.tokenNotGenerated
            }

            let userName = user.getUserName()

            let client = try request.client()
            return client.post("\(emailServiceAddress)/emails") { httpRequest in
                let emailAddress = EmailAddressDto(address: user.email, name: user.name)
                let email = EmailDto(to: emailAddress,
                                     title: "Letterer - Forgot password",
                                     body: "<html><body><div>Hi \(userName),</div><div>You can reset your password by clicking following <a href='https://letterer.me/reset-password?token=\(forgotPasswordGuid)'>link</a>.</div></body></html>")

                try httpRequest.content.encode(email)
            }

        }.transform(to: HTTPStatus.ok)
    }

    /// Changing password.
    func forgotPasswordConfirm(request: Request, confirmationDto: ForgotPasswordConfirmationRequestDto) throws -> Future<HTTPResponseStatus> {
        return User.query(on: request).filter(\.forgotPasswordGuid == confirmationDto.forgotPasswordGuid).first().flatMap(to: User.self) { userFromDb in

            try confirmationDto.validate()

            guard let user = userFromDb else {
                throw ForgotPasswordError.userNotExists
            }

            if user.isBlocked {
                throw ForgotPasswordError.userAccountIsBlocked
            }

            guard let forgotPasswordDate = user.forgotPasswordDate else {
                throw ForgotPasswordError.tokenExpired
            }

            let hoursDifference = Calendar.current.dateComponents([.minute], from: forgotPasswordDate, to: Date()).hour ?? 0
            if hoursDifference > 6 {
                throw ForgotPasswordError.tokenExpired
            }

            let salt = try Password.generateSalt()
            let passwordHash = try Password.hash(confirmationDto.password, withSalt: salt)

            user.forgotPasswordGuid = nil
            user.forgotPasswordDate = nil
            user.password = passwordHash
            user.salt = salt
            user.emailWasConfirmed = true

            return user.save(on: request)
        }.transform(to: HTTPStatus.ok)
    }
}
