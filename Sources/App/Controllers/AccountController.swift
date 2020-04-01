import Foundation
import Vapor
import JWT
import Crypto
import Recaptcha
import Fluent
import FluentPostgresDriver

final class AccountController: RouteCollection {

    public static let uri = "/account"

    func boot(routes: RoutesBuilder) throws {
        // routes.post(LoginRequestDto.self, at: "\(AccountController.uri)/login", use: login)
        // routes.post(RefreshTokenDto.self, at: "\(AccountController.uri)/refresh", use: refresh)
        // routes.post(ChangePasswordRequestDto.self, at: "\(AccountController.uri)/change-password", use: changePassword)
    }
/*
    /// Sign-in user.
    func login(request: Request, loginRequestDto: LoginRequestDto) throws -> EventLoopFuture<AccessTokenDto> {
        let usersService = request.application.services.usersService

        let loginFuture = try usersService.login(on: request, userNameOrEmail: loginRequestDto.userNameOrEmail, password: loginRequestDto.password)
        return loginFuture.flatMapThrowing { user in

            let authorizationService = request.application.services.authorizationService

            let accessTokenFuture = try authorizationService.createAccessToken(request: request, forUser: user)
            let refreshTokenFuture = try authorizationService.createRefreshToken(request: request, forUser: user)

            return map(to: AccessTokenDto.self, accessTokenFuture, refreshTokenFuture) { accessToken, refreshToken in
                return AccessTokenDto(accessToken: accessToken, refreshToken: refreshToken)
            }
        }
    }

    /// Refresh token.
    func refresh(request: Request, refreshTokenDto: RefreshTokenDto) throws -> EventLoopFuture<AccessTokenDto> {
        let authorizationService = request.application.services.authorizationService

        let validateRefreshTokenFuture = try authorizationService.validateRefreshToken(on: request, refreshToken: refreshTokenDto.refreshToken)
        return validateRefreshTokenFuture.flatMapThrowing { (user, refreshToken) in

            let accessTokenFuture = try authorizationService.createAccessToken(request: request, forUser: user)
            let refreshTokenFuture = try authorizationService.updateRefreshToken(request: request, forToken: refreshToken)

            return map(to: AccessTokenDto.self, accessTokenFuture, refreshTokenFuture) { accessToken, refreshToken in
                return AccessTokenDto(accessToken: accessToken, refreshToken: refreshToken)
            }
        }
    }

    /// Change password.
    func changePassword(request: Request, changePasswordRequestDto: ChangePasswordRequestDto) throws -> EventLoopFuture<HTTPStatus> {

        try ChangePasswordRequestDto.validate(request)

        let authorizationService = request.application.services.authorizationService
        let userNameFuture = try authorizationService.getUserNameFromBearerToken(request: request)
        return userNameFuture.flatMapThrowing { userNameFromToken in

            guard let unwrapedUserNameFromToken = userNameFromToken else {
                throw Abort(.unauthorized)
            }

            let usersService = request.application.services.usersService
            return try usersService.changePassword(
                on: request,
                userName: unwrapedUserNameFromToken,
                currentPassword: changePasswordRequestDto.currentPassword,
                newPassword: changePasswordRequestDto.newPassword
            ).transform(to: HTTPStatus.ok)
        }
    }
*/
}
