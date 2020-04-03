import Foundation
import Vapor
import JWT
import Crypto
import Recaptcha
import Fluent
import FluentPostgresDriver

final class AccountController: RouteCollection {

    public static let uri: PathComponent = .constant("account")

    func boot(routes: RoutesBuilder) throws {
        let accountGroup = routes.grouped(AccountController.uri)
        
        accountGroup.post("login", use: login)
        accountGroup.post("refresh", use: refresh)
        accountGroup
            .grouped(UserAuthenticator().middleware())
            .grouped(UserPayload.guardMiddleware())
            .post("change-password", use: changePassword)
    }

    /// Sign-in user.
    func login(request: Request) throws -> EventLoopFuture<AccessTokenDto> {
        let loginRequestDto = try request.content.decode(LoginRequestDto.self)
        let usersService = request.application.services.usersService

        let loginFuture = try usersService.login(on: request, userNameOrEmail: loginRequestDto.userNameOrEmail, password: loginRequestDto.password)
        return loginFuture.flatMap { user -> EventLoopFuture<AccessTokenDto> in

            let tokensService = request.application.services.tokensService

            do {
                let accessTokenFuture = try tokensService.createAccessToken(request: request, forUser: user)
                let refreshTokenFuture = try tokensService.createRefreshToken(request: request, forUser: user)
            
                let combinedFuture = accessTokenFuture.and(refreshTokenFuture)
                let resultAll = combinedFuture.map { (accessToken, refreshToken) in
                    AccessTokenDto(accessToken: accessToken, refreshToken: refreshToken)
                }
                
                return resultAll
            } catch {
                return request.eventLoop.makeFailedFuture(LoginError.invalidLoginCredentials)
            }
        }
    }

    /// Refresh token.
    func refresh(request: Request) throws -> EventLoopFuture<AccessTokenDto> {
        let refreshTokenDto = try request.content.decode(RefreshTokenDto.self)
        let tokensService = request.application.services.tokensService

        let validateRefreshTokenFuture = tokensService.validateRefreshToken(on: request, refreshToken: refreshTokenDto.refreshToken)
        
        let userAndTokenFuture = validateRefreshTokenFuture.map { refreshToken -> EventLoopFuture<(user: User, refreshToken: RefreshToken)> in
            return tokensService.getUserByRefreshToken(on: request, refreshToken: refreshToken.token).map { user in
                return (user, refreshToken)
            }
        }.flatMap { wrappedFuture in wrappedFuture }
        
        return userAndTokenFuture.flatMap { (user: User, refreshToken: RefreshToken) -> EventLoopFuture<AccessTokenDto> in
            do {
                 let accessTokenFuture = try tokensService.createAccessToken(request: request, forUser: user)
                 let refreshTokenFuture = try tokensService.updateRefreshToken(request: request, forToken: refreshToken)
             
                 let combinedFuture = accessTokenFuture.and(refreshTokenFuture)
                 let resultAll = combinedFuture.map { (accessToken, refreshToken) in
                     AccessTokenDto(accessToken: accessToken, refreshToken: refreshToken)
                 }
                 
                 return resultAll
             } catch {
                 return request.eventLoop.makeFailedFuture(LoginError.invalidLoginCredentials)
             }
        }
    }

    /// Change password.
    func changePassword(request: Request) throws -> EventLoopFuture<HTTPStatus> {
        let authorizationPayload = try request.auth.require(UserPayload.self)

        let changePasswordRequestDto = try request.content.decode(ChangePasswordRequestDto.self)
        try ChangePasswordRequestDto.validate(request)

        let usersService = request.application.services.usersService
        return try usersService.changePassword(
            on: request,
            userId: authorizationPayload.id,
            currentPassword: changePasswordRequestDto.currentPassword,
            newPassword: changePasswordRequestDto.newPassword
        ).transform(to: HTTPStatus.ok)
    }
}
