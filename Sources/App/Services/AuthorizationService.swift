import Vapor
import JWT
import Crypto
import FluentPostgreSQL

protocol AuthorizationServiceType: Service {
    func validateRefreshToken(on request: Request, refreshToken: String) throws -> Future<(user: User, refreshToken: RefreshToken)>
    func createAccessToken(request: Request, forUser user: User) throws -> Future<String>
    func createRefreshToken(request: Request, forUser user: User) throws -> Future<String>
    func updateRefreshToken(request: Request, forToken refreshToken: RefreshToken) throws -> Future<String>
    func getUserIdFromBearerToken(request: Request) throws -> Future<UUID?>
    func getUserNameFromBearerToken(request: Request) throws -> Future<String?>
}

final class AuthorizationService: AuthorizationServiceType {

    private let refreshTokenTime: TimeInterval = 30 * 24 * 60 * 60  // 30 days
    private let accessTokenTime: TimeInterval = 60 * 60             // 1 hour

    public func validateRefreshToken(on request: Request, refreshToken: String) throws -> Future<(user: User, refreshToken: RefreshToken)> {
        return RefreshToken.query(on: request).filter(\.token == refreshToken)
            .first().flatMap(to: (user: User, refreshToken: RefreshToken).self) { refreshTokenFromDb in

                guard let refreshToken = refreshTokenFromDb else {
                    throw RefreshTokenError.refreshTokenNotExists
                }

                if refreshToken.revoked {
                    throw RefreshTokenError.refreshTokenNotExists
                }

                if refreshToken.expiryDate < Date()  {
                    throw RefreshTokenError.refreshTokenNotExists
                }

                return User.query(on: request).filter(\.id == refreshToken.userId).first().map { userFromDb in

                    guard let user = userFromDb else {
                        throw UserError.userNotExists
                    }

                    if user.isBlocked {
                        throw LoginError.userAccountIsBlocked
                    }

                    return (user, refreshToken)
                }
        }
    }

    public func createAccessToken(request: Request, forUser user: User) throws -> Future<String> {
        let settingsService = try request.make(SettingsServiceType.self)
        return try settingsService.get(on: request).map(to: String.self) { configuration in

            guard let jwtPrivateKey = configuration.getString(.jwtPrivateKey) else {
                throw Abort(.internalServerError, reason: "Private key is not configured in database.")
            }

            let rsaKey: RSAKey = try .private(pem: jwtPrivateKey)
            let authorizationPayload = self.createAuthorizationPayload(forUser: user)
            let data = try JWT(payload: authorizationPayload).sign(using: JWTSigner.rs512(key: rsaKey))
            let accessToken = String(data: data, encoding: .utf8) ?? ""

            return accessToken
        }
    }

    public func createRefreshToken(request: Request, forUser user: User) throws -> Future<String> {

        guard let userId = user.id else {
            throw RefreshTokenError.userIdNotSpecified
        }

        let token = self.createRefreshTokenString()
        let expiryDate = Date().addingTimeInterval(self.refreshTokenTime)
        let refreshToken = RefreshToken(userId: userId, token: token, expiryDate: expiryDate)

        return refreshToken.save(on: request).transform(to: refreshToken.token)
    }

    public func updateRefreshToken(request: Request, forToken refreshToken: RefreshToken) throws -> Future<String> {
        refreshToken.token = self.createRefreshTokenString()
        refreshToken.expiryDate = Date().addingTimeInterval(self.refreshTokenTime)

        return refreshToken.save(on: request).transform(to: refreshToken.token)
    }

    public func getUserIdFromBearerToken(request: Request) throws -> Future<UUID?> {
        return try self.geAuthorizationPayloadFromBearerToken(request: request).map(to: UUID?.self) { authorizationPayload in
            guard let unwrapedAuthorizationPayload = authorizationPayload else {
                return nil
            }

            return unwrapedAuthorizationPayload.id
        }
    }

    public func getUserNameFromBearerToken(request: Request) throws -> Future<String?> {
        return try self.geAuthorizationPayloadFromBearerToken(request: request).map(to: String?.self) { authorizationPayload in
            guard let unwrapedAuthorizationPayload = authorizationPayload else {
                return nil
            }

            return unwrapedAuthorizationPayload.userName
        }
    }

    private func geAuthorizationPayloadFromBearerToken(request: Request) throws -> Future<AuthorizationPayload?> {

        if let bearer = request.http.headers.bearerAuthorization {

            let settingsService = try request.make(SettingsServiceType.self)
            return try settingsService.get(on: request).map(to: AuthorizationPayload?.self) { configuration in

                guard let jwtPrivateKey = configuration.getString(.jwtPrivateKey) else {
                    throw Abort(.internalServerError, reason: "Private key is not configured in database.")
                }

                let rsaKey: RSAKey = try .private(pem: jwtPrivateKey)
                let authorizationPayload = try JWT<AuthorizationPayload>(from: bearer.token, verifiedUsing: JWTSigner.rs512(key: rsaKey))

                if authorizationPayload.payload.exp > Date() {
                    return authorizationPayload.payload
                }

                return nil
            }
        }

        return Future.map(on: request) { return nil }
    }

    private func createAuthorizationPayload(forUser user: User) -> AuthorizationPayload {
        let expirationDate = Date().addingTimeInterval(TimeInterval(self.accessTokenTime))
        let authorizationPayload = AuthorizationPayload(
            id: user.id,
            userName: user.userName,
            name: user.name,
            email: user.email,
            exp: expirationDate,
            gravatarHash: user.gravatarHash
        )

        return authorizationPayload
    }

    private func createRefreshTokenString() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0 ... 40).map { _ in letters.randomElement()! })
    }
}
