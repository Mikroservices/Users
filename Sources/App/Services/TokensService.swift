import Vapor
import JWT
import Crypto
import Fluent
import FluentPostgresDriver

extension Application.Services {
    struct TokensServiceKey: StorageKey {
        typealias Value = TokensServiceType
    }

    var tokensService: TokensServiceType {
        get {
            self.application.storage[TokensServiceKey.self] ?? TokensService()
        }
        nonmutating set {
            self.application.storage[TokensServiceKey.self] = newValue
        }
    }
}

protocol TokensServiceType {
    func validateRefreshToken(on request: Request, refreshToken: String) -> EventLoopFuture<RefreshToken>
    func getUserByRefreshToken(on request: Request, refreshToken: String) -> EventLoopFuture<User>
    func createAccessToken(request: Request, forUser user: User) throws -> EventLoopFuture<String>
    func createRefreshToken(request: Request, forUser user: User) throws -> EventLoopFuture<String>
    func updateRefreshToken(request: Request, forToken refreshToken: RefreshToken) throws -> EventLoopFuture<String>
}

final class TokensService: TokensServiceType {

    private let refreshTokenTime: TimeInterval = 30 * 24 * 60 * 60  // 30 days
    private let accessTokenTime: TimeInterval = 60 * 60             // 1 hour

    public func validateRefreshToken(on request: Request, refreshToken: String) -> EventLoopFuture<RefreshToken> {
        return RefreshToken.query(on: request.db).filter(\.$token == refreshToken).first().flatMap { refreshTokenFromDb in

            guard let refreshToken = refreshTokenFromDb else {
                return request.fail(EntityNotFoundError.refreshTokenNotFound)
            }

            if refreshToken.revoked {
                return request.fail(RefreshTokenError.refreshTokenRevoked)
            }

            if refreshToken.expiryDate < Date()  {
                return request.fail(RefreshTokenError.refreshTokenExpired)
            }
            
            return request.success(refreshToken)
        }
    }
    
    public func getUserByRefreshToken(on request: Request, refreshToken: String) -> EventLoopFuture<User> {
        let refreshTokenFuture = RefreshToken.query(on: request.db).with(\.$user).filter(\.$token == refreshToken).first()
        
        let userFuture = refreshTokenFuture.flatMap { refreshTokenFromDb -> EventLoopFuture<User> in
            
            guard let refreshToken = refreshTokenFromDb else {
                return request.fail(EntityNotFoundError.refreshTokenNotFound)
            }
            
            if refreshToken.user.isBlocked {
                return request.fail(LoginError.userAccountIsBlocked)
            }

            return request.success(refreshToken.user)
        }
        
        return userFuture
    }

    public func createAccessToken(request: Request, forUser user: User) throws -> EventLoopFuture<String> {
        let authorizationPayloadFlatFuture = try self.createAuthenticationPayload(request: request, forUser: user)

        return authorizationPayloadFlatFuture.flatMapThrowing { authorizationPayload in
            let accessToken = try request.jwt.sign(authorizationPayload)
            return accessToken
        }
    }

    public func createRefreshToken(request: Request, forUser user: User) throws -> EventLoopFuture<String> {

        guard let userId = user.id else {
            throw RefreshTokenError.userIdNotSpecified
        }

        let token = self.createRefreshTokenString()
        let expiryDate = Date().addingTimeInterval(self.refreshTokenTime)
        let refreshToken = RefreshToken(userId: userId, token: token, expiryDate: expiryDate)

        return refreshToken.save(on: request.db).map {
            refreshToken.token
        }
    }

    public func updateRefreshToken(request: Request, forToken refreshToken: RefreshToken) throws -> EventLoopFuture<String> {
        refreshToken.token = self.createRefreshTokenString()
        refreshToken.expiryDate = Date().addingTimeInterval(self.refreshTokenTime)

        return refreshToken.save(on: request.db).map {
            refreshToken.token
        }
    }

    private func createAuthenticationPayload(request: Request, forUser user: User) throws -> EventLoopFuture<UserPayload> {

        guard let userId = user.id else {
            throw Abort(.unauthorized)
        }
        
        return User.query(on: request.db).with(\.$roles).filter(\.$id == userId).first().map { userFromDb in

            let expirationDate = Date().addingTimeInterval(TimeInterval(self.accessTokenTime))
            
            let superUserRoles = userFromDb?.roles.filter({ $0.hasSuperPrivileges == true }).count
            var isSuperUser = false
            if let superUserRoles = superUserRoles {
                isSuperUser = superUserRoles > 0
            }
            
            let authorizationPayload = UserPayload(
                id: userId,
                userName: user.userName,
                email: user.email,
                name: user.name,
                exp: expirationDate,
                gravatarHash: user.gravatarHash,
                roles: userFromDb?.roles.map { $0.code } ?? [],
                isSuperUser: isSuperUser
            )

            return authorizationPayload
        }
    }

    private func createRefreshTokenString() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0 ... 40).map { _ in letters.randomElement()! })
    }
}
