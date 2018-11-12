//
//  LoginController.swift
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

final class LoginController: RouteCollection {

    func boot(router: Router) throws {
        router.post(SignInRequestDto.self, at: "/login", use: login)
    }

    /// Sign-in user.
    func login(request: Request, signInRequestDto: SignInRequestDto) throws -> Future<SignInResponseDto> {
        return User.query(on: request).filter(\.email == signInRequestDto.email).first().map(to: SignInResponseDto.self) { userFromDb in

            guard let user = userFromDb else {
                throw Abort(.badRequest, reason: "INVALID_EMAIL_OR_PASSWORD")
            }

            let passwordHash = try Password.hash(signInRequestDto.password, withSalt: user.salt)
            if user.password != passwordHash {
                throw Abort(.badRequest, reason: "INVALID_EMAIL_OR_PASSWORD")
            }

            if !user.emailWasConfirmed {
                throw Abort(.badRequest, reason: "USER_EMAIL_WAS_NOT_CONFIRMED")
            }

            if user.isBlocked {
                throw Abort(.badRequest, reason: "USER_ACCOUNT_IS_BLOCKED")
            }

            // Create payload.
            let accessToken = try self.createAccessToken(request: request, forUser: user)
            return SignInResponseDto(accessToken)
        }
    }

    private func createAccessToken(request: Request, forUser user: User) throws -> String {

        let authorizationPayload = self.createAuthorizationPayload(forUser: user)

        let settingsStorage = try request.make(SettingsStorage.self)
        let rsaKey: RSAKey = try .private(pem: settingsStorage.privateKey)
        let data = try JWT(payload: authorizationPayload).sign(using: JWTSigner.rs512(key: rsaKey))
        let accessToken = String(data: data, encoding: .utf8) ?? ""

        return accessToken
    }

    private func createAuthorizationPayload(forUser user: User) -> AuthorizationPayload {
        let expirationDate = Date().addingTimeInterval(TimeInterval(3600.0))
        let authorizationPayload = AuthorizationPayload(
            id: user.id,
            name: user.name,
            email: user.email,
            exp: expirationDate
        )

        return authorizationPayload
    }
}
