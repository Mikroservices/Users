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
        let accountGroup = routes.grouped("account")
        
        accountGroup.post("login", use: login)
        accountGroup.post("refresh", use: refresh)
        // routes.post(ChangePasswordRequestDto.self, at: "\(AccountController.uri)/change-password", use: changePassword)
    }

    /// Sign-in user.
    func login(request: Request) throws -> EventLoopFuture<AccessTokenDto> {
        let loginRequestDto = try request.content.decode(LoginRequestDto.self)
        let usersService = request.application.services.usersService

        let loginFuture = try usersService.login(on: request, userNameOrEmail: loginRequestDto.userNameOrEmail, password: loginRequestDto.password)
        return loginFuture.flatMap { user -> EventLoopFuture<AccessTokenDto> in

            let authorizationService = request.application.services.authorizationService

            do {
                let accessTokenFuture = try authorizationService.createAccessToken(request: request, forUser: user)
                let refreshTokenFuture = try authorizationService.createRefreshToken(request: request, forUser: user)
            
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
        let authorizationService = request.application.services.authorizationService

        let validateRefreshTokenFuture = authorizationService.validateRefreshToken(on: request, refreshToken: refreshTokenDto.refreshToken)
        
        
        let userAndTokenFuture = validateRefreshTokenFuture.map { refreshToken -> EventLoopFuture<(user: User, refreshToken: RefreshToken)> in
            return authorizationService.getUserByRefreshToken(on: request, refreshToken: refreshToken.token).map { user in
                return (user, refreshToken)
            }
        }.flatMap { wrappedFuture in wrappedFuture }
        
        return userAndTokenFuture.flatMap { (user: User, refreshToken: RefreshToken) -> EventLoopFuture<AccessTokenDto> in
            do {
                 let accessTokenFuture = try authorizationService.createAccessToken(request: request, forUser: user)
                 let refreshTokenFuture = try authorizationService.updateRefreshToken(request: request, forToken: refreshToken)
             
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
/*
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
