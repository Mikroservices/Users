//
//  UsersController.swift
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

/// Controls basic operations for User object.
final class UsersController: RouteCollection {

    func boot(router: Router) throws {
        router.get("/users", String.parameter, use: profile)
    }

    /// User profile.
    func profile(request: Request) throws -> Future<UserDto> {

        let userNameNormalized = try request.parameters.next(String.self).uppercased().replacingOccurrences(of: "@", with: "")

        return User.query(on: request).filter(\.userNameNormalized == userNameNormalized).first().map(to: UserDto.self) { userFromDb in

            guard let user = userFromDb else {
                throw UserError.userNotExists
            }

            let userDto = UserDto(from: user)

            let userNameFromToken = try self.getUserNameFromBearerToken(request: request)
            let isProfileOwner = userNameFromToken == userNameNormalized

            if !isProfileOwner {
                userDto.email = ""
            }

            return userDto
        }
    }

    private func getUserNameFromBearerToken(request: Request) throws -> String {
        var userNameFromToken: String = ""
        if let bearer = request.http.headers.bearerAuthorization {

            let settingsStorage = try request.make(SettingsStorage.self)
            let rsaKey: RSAKey = try .private(pem: settingsStorage.privateKey)
            let authorizationPayload = try JWT<AuthorizationPayload>(from: bearer.token, verifiedUsing: JWTSigner.rs512(key: rsaKey))

            if authorizationPayload.payload.exp > Date() {
                userNameFromToken = authorizationPayload.payload.userName.uppercased()
            }
        }

        return userNameFromToken
    }
}
