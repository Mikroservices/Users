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
        router.get("/users", UUID.parameter, use: profile)
    }

    /// User profile.
    func profile(request: Request) throws -> Future<UserDto> {

        let userIdFromParameter = try request.parameters.next(UUID.self)

        return User.find(userIdFromParameter, on: request).map(to: UserDto.self) { userFromDb in

            guard let user = userFromDb else {
                throw Abort(.badRequest, reason: "USER_WITH_ID_NOT_EXISTS")
            }

            let userDto = UserDto(from: user)

            let userIdFromToken = try self.getUserIdFromBearerToken(request: request)
            let isProfileOwner = userIdFromToken == userIdFromParameter

            if !isProfileOwner {
                userDto.email = ""
            }

            return userDto
        }
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
