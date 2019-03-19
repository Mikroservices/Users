//
//  AuthorizationService.swift
//  App
//
//  Created by Marcin Czachurski on 17/11/2018.
//

import Vapor
import JWT
import Crypto

final class AuthorizationService: ServiceType {

    private let refreshTokenTime: TimeInterval = 30 * 24 * 60 * 60  // 30 days
    private let accessTokenTime: TimeInterval = 60 * 60             // 1 hour

    static func makeService(for worker: Container) throws -> AuthorizationService {
        return AuthorizationService()
    }

    public func createAccessToken(request: Request, forUser user: User) throws -> String {

        let authorizationPayload = self.createAuthorizationPayload(forUser: user)

        let settingsStorage = try request.make(SettingsStorage.self)
        let rsaKey: RSAKey = try .private(pem: settingsStorage.privateKey)
        let data = try JWT(payload: authorizationPayload).sign(using: JWTSigner.rs512(key: rsaKey))
        let accessToken = String(data: data, encoding: .utf8) ?? ""

        return accessToken
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

    public func getUserIdFromBearerToken(request: Request) throws -> UUID? {
        guard let authorizationPayload = try self.geAuthorizationPayloadFromBearerToken(request: request) else {
            return nil
        }

        return authorizationPayload.id
    }

    public func getUserNameFromBearerToken(request: Request) throws -> String? {
        guard let authorizationPayload = try self.geAuthorizationPayloadFromBearerToken(request: request) else {
            return nil
        }

        return authorizationPayload.userName
    }

    private func geAuthorizationPayloadFromBearerToken(request: Request) throws -> AuthorizationPayload? {

        if let bearer = request.http.headers.bearerAuthorization {

            let settingsStorage = try request.make(SettingsStorage.self)
            let rsaKey: RSAKey = try .private(pem: settingsStorage.privateKey)
            let authorizationPayload = try JWT<AuthorizationPayload>(from: bearer.token, verifiedUsing: JWTSigner.rs512(key: rsaKey))

            if authorizationPayload.payload.exp > Date() {
                return authorizationPayload.payload
            }
        }

        return nil
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
