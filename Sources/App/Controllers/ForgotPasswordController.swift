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
        return User.query(on: request).filter(\.email == forgotPasswordRequestDto.email).first().flatMap(to: User.self) { userFromDb in

            guard let user = userFromDb else {
                throw Abort(.badRequest, reason: "USER_NOT_EXISTS")
            }

            if user.isBlocked {
                throw Abort(.badRequest, reason: "USER_ACCOUNT_IS_BLOCKED")
            }

            user.forgotPasswordGuid = UUID.init().uuidString
            user.forgotPasswordDate = Date()

            return user.save(on: request)
        }.flatMap(to: Response.self) { user in
            let client = try request.client()
            let settingsStorage = try request.make(SettingsStorage.self)

            guard let forgotPasswordGuid = user.forgotPasswordGuid else {
                throw Abort(.badRequest, reason: "FORGOT_PASSWORD_TOKEN_WAS_NOT_GENERATED")
            }

            return client.post("\(settingsStorage.emailServiceAddress)/emails") { httpRequest in
                let emailAddress = EmailAddressDto(address: user.email, name: user.name)
                let email = EmailDto(to: emailAddress,
                                     title: "Letterer - Forgot password",
                                     body: "<html><body><div>Hi \(user.name),</div><div>You can reset your password by clicking following <a href='https://letterer.me/forgot-password?token=\(forgotPasswordGuid)'>link</a>.</div></body></html>")

                try httpRequest.content.encode(email)
            }
        }.transform(to: HTTPStatus.ok)
    }

    /// Changing password.
    func forgotPasswordConfirm(request: Request, confirmationDto: ForgotPasswordConfirmationRequestDto) throws -> Future<HTTPResponseStatus> {
        return User.query(on: request).filter(\.forgotPasswordGuid == confirmationDto.forgotPasswordGuid).first().flatMap(to: User.self) { userFromDb in

            try confirmationDto.validate()

            guard let user = userFromDb else {
                throw Abort(.badRequest, reason: "USER_NOT_EXISTS")
            }

            if user.isBlocked {
                throw Abort(.badRequest, reason: "USER_ACCOUNT_IS_BLOCKED")
            }

            guard let forgotPasswordDate = user.forgotPasswordDate else {
                throw Abort(.badRequest, reason: "INVALID_FORGOT_PASSWORD_DATE")
            }

            let hoursDifference = Calendar.current.dateComponents([.minute], from: forgotPasswordDate, to: Date()).hour ?? 0
            if hoursDifference > 6 {
                throw Abort(.badRequest, reason: "FORGOT_PASSWORD_DATE_EXPIRED")
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

    private func getUserIdFromBearerToken(request: Request) throws -> UUID? {
        var userIdFromToken: UUID?
        if let bearer = request.http.headers.bearerAuthorization {

            let settingsStorage = try request.make(SettingsStorage.self)
            let rsaKey: RSAKey = try .private(pem: settingsStorage.privateKey)
            let authorizationPayload = try JWT<AuthorizationPayload>(from: bearer.token, verifiedUsing: JWTSigner.rs512(key: rsaKey))

            if authorizationPayload.payload.exp < Date() {
                userIdFromToken = authorizationPayload.payload.id
            }
        }

        return userIdFromToken
    }
}
