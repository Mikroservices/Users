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
        router.post(LoginRequestDto.self, at: "/login", use: login)
    }

    /// Sign-in user.
    func login(request: Request, loginRequestDto: LoginRequestDto) throws -> Future<LoginResponseDto> {

        let userNameOrEmailNormalized = loginRequestDto.userNameOrEmail.uppercased()

        return User.query(on: request).group(.or) { userNameGroup in
                userNameGroup.filter(\.userNameNormalized == userNameOrEmailNormalized)
                userNameGroup.filter(\.emailNormalized == userNameOrEmailNormalized)
            }.first().map(to: LoginResponseDto.self) { userFromDb in

            guard let user = userFromDb else {
                throw LoginError.invalidLoginCredentials
            }

            let passwordHash = try Password.hash(loginRequestDto.password, withSalt: user.salt)
            if user.password != passwordHash {
                throw LoginError.invalidLoginCredentials
            }

            if !user.emailWasConfirmed {
                throw LoginError.emailNotConfirmed
            }

            if user.isBlocked {
                throw LoginError.userAccountIsBlocked
            }

            // Create payload.
            let accessToken = try self.createAccessToken(request: request, forUser: user)
            return LoginResponseDto(accessToken)
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
            userName: user.userName,
            name: user.name,
            email: user.email,
            exp: expirationDate
        )

        return authorizationPayload
    }
}
