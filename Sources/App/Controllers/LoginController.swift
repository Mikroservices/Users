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
                throw LoginError.invalidEmailOrPassword
            }

            let passwordHash = try Password.hash(signInRequestDto.password, withSalt: user.salt)
            if user.password != passwordHash {
                throw LoginError.invalidEmailOrPassword
            }

            if !user.emailWasConfirmed {
                throw LoginError.emailNotConfirmed
            }

            if user.isBlocked {
                throw LoginError.userAccountIsBlocked
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
