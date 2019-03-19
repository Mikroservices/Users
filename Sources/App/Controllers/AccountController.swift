//
//  AccountController.swift
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

final class AccountController: RouteCollection {

    func boot(router: Router) throws {
        router.post(LoginRequestDto.self, at: "/account/login", use: login)
        router.post(RefreshTokenDto.self, at: "/account/refresh", use: refresh)
        router.post(ChangePasswordRequestDto.self, at: "/account/change-password", use: changePassword)
    }

    /// Sign-in user.
    func login(request: Request, loginRequestDto: LoginRequestDto) throws -> Future<AccessTokenDto> {

        let userNameOrEmailNormalized = loginRequestDto.userNameOrEmail.uppercased()

        return User.query(on: request).group(.or) { userNameGroup in
                userNameGroup.filter(\.userNameNormalized == userNameOrEmailNormalized)
                userNameGroup.filter(\.emailNormalized == userNameOrEmailNormalized)
            }.first().flatMap(to: AccessTokenDto.self) { userFromDb in

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

            let authorizationService = try request.make(AuthorizationService.self)

            return try authorizationService.createRefreshToken(request: request, forUser: user).map(to: AccessTokenDto.self) { refreshToken in
                let accessToken = try authorizationService.createAccessToken(request: request, forUser: user)
                return AccessTokenDto(accessToken: accessToken, refreshToken: refreshToken)
            }
        }
    }

    /// Refresh token.
    func refresh(request: Request, refreshTokenDto: RefreshTokenDto) throws -> Future<AccessTokenDto> {

        return RefreshToken.query(on: request).filter(\.token == refreshTokenDto.refreshToken)
            .first().flatMap(to: (User?, RefreshToken).self) { refreshTokenFromDb in

            guard let refreshToken = refreshTokenFromDb else {
                throw RefreshTokenError.refreshTokenNotExists
            }

            if refreshToken.revoked {
                throw RefreshTokenError.refreshTokenNotExists
            }

            if refreshToken.expiryDate < Date()  {
                throw RefreshTokenError.refreshTokenNotExists
            }

            return User.query(on: request).filter(\.id == refreshToken.userId).first().map { user in
                return (user, refreshToken)
            }
        }.flatMap(to: AccessTokenDto.self) { (userFromDb, refreshToken) in

            guard let user = userFromDb else {
                throw LoginError.userAccountIsBlocked
            }

            let authorizationService = try request.make(AuthorizationService.self)

            return try authorizationService.updateRefreshToken(request: request, forToken: refreshToken).map(to: AccessTokenDto.self) { refreshToken in
                let accessToken = try authorizationService.createAccessToken(request: request, forUser: user)
                return AccessTokenDto(accessToken: accessToken, refreshToken: refreshToken)
            }
        }
    }

    /// Change password.
    func changePassword(request: Request, changePasswordRequestDto: ChangePasswordRequestDto) throws -> Future<HTTPStatus> {

        let authorizationService = try request.make(AuthorizationService.self)
        guard let userNameFromToken = try authorizationService.getUserNameFromBearerToken(request: request) else {
            throw Abort(.unauthorized)
        }

        let userNameNormalized = userNameFromToken.uppercased()

        return User.query(on: request).filter(\.userNameNormalized == userNameNormalized).first().flatMap(to: User.self) { userFromDb in

            guard let user = userFromDb else {
                throw LoginError.invalidLoginCredentials
            }

            let currentPasswordHash = try Password.hash(changePasswordRequestDto.currentPassword, withSalt: user.salt)
            if user.password != currentPasswordHash {
                throw LoginError.invalidLoginCredentials
            }

            if !user.emailWasConfirmed {
                throw LoginError.emailNotConfirmed
            }

            if user.isBlocked {
                throw LoginError.userAccountIsBlocked
            }

            let salt = try Password.generateSalt()
            let newPasswordHash = try Password.hash(changePasswordRequestDto.newPassword, withSalt: salt)

            user.password = newPasswordHash
            user.salt = salt

            return user.update(on: request)
        }.transform(to: HTTPStatus.ok)
    }
}
