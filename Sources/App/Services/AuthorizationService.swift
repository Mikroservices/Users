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
        let expirationDate = Date().addingTimeInterval(TimeInterval(3600.0))
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

}
