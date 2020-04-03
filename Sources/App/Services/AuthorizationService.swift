import Vapor
import JWT
import Crypto
import Fluent
import FluentPostgresDriver

extension Application.Services {
    struct AuthorizationServiceKey: StorageKey {
        typealias Value = AuthorizationServiceType
    }

    var authorizationService: AuthorizationServiceType {
        get {
            self.application.storage[AuthorizationServiceKey.self] ?? AuthorizationService()
        }
        nonmutating set {
            self.application.storage[AuthorizationServiceKey.self] = newValue
        }
    }
}

protocol AuthorizationServiceType {
    func validateRefreshToken(on request: Request, refreshToken: String) -> EventLoopFuture<RefreshToken>
    func getUserByRefreshToken(on request: Request, refreshToken: String) -> EventLoopFuture<User>
    func createAccessToken(request: Request, forUser user: User) throws -> EventLoopFuture<String>
    func createRefreshToken(request: Request, forUser user: User) throws -> EventLoopFuture<String>
    func updateRefreshToken(request: Request, forToken refreshToken: RefreshToken) throws -> EventLoopFuture<String>
    func getUserIdFromBearerToken(request: Request) throws -> UUID?
    func getUserNameFromBearerToken(request: Request) throws -> String?
    func getUserNameFromBearerTokenOrAbort(on request: Request) throws -> String
    func verifySuperUser(request: Request) throws -> EventLoopFuture<Void>
}

final class AuthorizationService: AuthorizationServiceType {

    private let refreshTokenTime: TimeInterval = 30 * 24 * 60 * 60  // 30 days
    private let accessTokenTime: TimeInterval = 60 * 60             // 1 hour

    public func validateRefreshToken(on request: Request, refreshToken: String) -> EventLoopFuture<RefreshToken> {
        return RefreshToken.query(on: request.db).filter(\.$token == refreshToken).first().flatMap { refreshTokenFromDb in

            guard let refreshToken = refreshTokenFromDb else {
                return request.eventLoop.makeFailedFuture(EntityNotFoundError.refreshTokenNotFound)
            }

            if refreshToken.revoked {
                return request.eventLoop.makeFailedFuture(RefreshTokenError.refreshTokenRevoked)
            }

            if refreshToken.expiryDate < Date()  {
                return request.eventLoop.makeFailedFuture(RefreshTokenError.refreshTokenExpired)
            }
            
            return request.eventLoop.makeSucceededFuture(refreshToken)
        }
    }
    
    public func getUserByRefreshToken(on request: Request, refreshToken: String) -> EventLoopFuture<User> {
        let refreshTokenFuture = RefreshToken.query(on: request.db).with(\.$user).filter(\.$token == refreshToken).first()
        
        let userFuture = refreshTokenFuture.flatMap { refreshTokenFromDb -> EventLoopFuture<User> in
            
            guard let refreshToken = refreshTokenFromDb else {
                return request.eventLoop.makeFailedFuture(EntityNotFoundError.refreshTokenNotFound)
            }
            
            if refreshToken.user.isBlocked {
                return request.eventLoop.makeFailedFuture(LoginError.userAccountIsBlocked)
            }

            return request.eventLoop.makeSucceededFuture(refreshToken.user)
        }
        
        return userFuture
    }

    public func createAccessToken(request: Request, forUser user: User) throws -> EventLoopFuture<String> {
        let authorizationPayloadFlatFuture = try self.createAuthorizationPayload(request: request, forUser: user)

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

    public func getUserIdFromBearerToken(request: Request) throws -> UUID? {
        let authorizationPayload = try self.geAuthorizationPayloadFromBearerToken(request: request)
        guard let unwrapedAuthorizationPayload = authorizationPayload else {
            return nil
        }

        return unwrapedAuthorizationPayload.id
    }

    public func getUserNameFromBearerToken(request: Request) throws -> String? {
        let authorizationPayload = try self.geAuthorizationPayloadFromBearerToken(request: request)
        guard let unwrapedAuthorizationPayload = authorizationPayload else {
            return nil
        }

        return unwrapedAuthorizationPayload.userName
    }

    private func geAuthorizationPayloadFromBearerToken(request: Request) throws -> AuthorizationPayload? {
        if let bearer = request.headers.bearerAuthorization {
            let authorizationPayload = try request.jwt.verify(bearer.token, as: AuthorizationPayload.self)

            if authorizationPayload.exp > Date() {
                return authorizationPayload
            }

            return nil
        }

        return nil
    }

    public func getUserNameFromBearerTokenOrAbort(on request: Request) throws -> String {
        let userNameFromToken = try self.getUserNameFromBearerToken(request: request)
        guard let unwrapedUserNameFromToken = userNameFromToken else {
            throw Abort(.unauthorized)
        }

        return unwrapedUserNameFromToken
    }

    public func verifySuperUser(request: Request) throws -> EventLoopFuture<Void> {

        let userNameFromToken = try self.getUserNameFromBearerTokenOrAbort(on: request)
        let userNameNormalized = userNameFromToken.uppercased()
        
        let userFuture = User.query(on: request.db).with(\.$roles).filter(\.$userNameNormalized == userNameNormalized).first()
        return userFuture.flatMapThrowing { userFromDb in
            guard let user = userFromDb else {
                throw Abort(.unauthorized)
            }

            if user.roles.filter({ $0.hasSuperPrivileges == true }).count == 0 {
                throw Abort(.forbidden)
            }
        }
    }

    private func createAuthorizationPayload(request: Request, forUser user: User) throws -> EventLoopFuture<AuthorizationPayload> {

        guard let userId = user.id else {
            throw Abort(.unauthorized)
        }
        
        return User.query(on: request.db).with(\.$roles).filter(\.$id == userId).first().map { userFromDb in

            let expirationDate = Date().addingTimeInterval(TimeInterval(self.accessTokenTime))
            let authorizationPayload = AuthorizationPayload(
                id: userId,
                userName: user.userName,
                name: user.name,
                email: user.email,
                exp: expirationDate,
                gravatarHash: user.gravatarHash,
                roles: userFromDb?.roles.map { $0.code } ?? []
            )

            return authorizationPayload
        }
    }

    private func createRefreshTokenString() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0 ... 40).map { _ in letters.randomElement()! })
    }
}
