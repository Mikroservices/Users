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
        let usersService = try request.make(UsersService.self)

        let loginFuture = try usersService.login(on: request, userNameOrEmail: loginRequestDto.userNameOrEmail, password: loginRequestDto.password)
        return loginFuture.flatMap(to: AccessTokenDto.self) { user in

            let authorizationService = try request.make(AuthorizationService.self)

            let accessTokenFuture = try authorizationService.createAccessToken(request: request, forUser: user)
            let refreshTokenFuture = try authorizationService.createRefreshToken(request: request, forUser: user)

            return map(to: AccessTokenDto.self, accessTokenFuture, refreshTokenFuture) { accessToken, refreshToken in
                return AccessTokenDto(accessToken: accessToken, refreshToken: refreshToken)
            }
        }
    }

    /// Refresh token.
    func refresh(request: Request, refreshTokenDto: RefreshTokenDto) throws -> Future<AccessTokenDto> {
        let authorizationService = try request.make(AuthorizationService.self)

        let validateRefreshTokenFuture = try authorizationService.validateRefreshToken(on: request, refreshToken: refreshTokenDto.refreshToken)
        return validateRefreshTokenFuture.flatMap(to: AccessTokenDto.self) { (user, refreshToken) in

            let accessTokenFuture = try authorizationService.createAccessToken(request: request, forUser: user)
            let refreshTokenFuture = try authorizationService.updateRefreshToken(request: request, forToken: refreshToken)

            return map(to: AccessTokenDto.self, accessTokenFuture, refreshTokenFuture) { accessToken, refreshToken in
                return AccessTokenDto(accessToken: accessToken, refreshToken: refreshToken)
            }
        }
    }

    /// Change password.
    func changePassword(request: Request, changePasswordRequestDto: ChangePasswordRequestDto) throws -> Future<HTTPStatus> {
        let authorizationService = try request.make(AuthorizationService.self)

        let userNameFuture = try authorizationService.getUserNameFromBearerToken(request: request)
        return userNameFuture.flatMap(to: User.self) { userNameFromToken in

            guard let unwrapedUserNameFromToken = userNameFromToken else {
                throw Abort(.unauthorized)
            }

            let usersService = try request.make(UsersService.self)
            return try usersService.changePassword(
                on: request,
                userName: unwrapedUserNameFromToken,
                currentPassword: changePasswordRequestDto.currentPassword,
                newPassword: changePasswordRequestDto.newPassword
            )
        }.transform(to: HTTPStatus.ok)
    }
}
