import Vapor
import Fluent

extension Application.Services {
    struct ExternalUsersServiceTypeKey: StorageKey {
        typealias Value = ExternalUsersServiceType
    }

    var externalUsersService: ExternalUsersServiceType {
        get {
            self.application.storage[ExternalUsersServiceTypeKey.self] ?? ExternalUsersService()
        }
        nonmutating set {
            self.application.storage[ExternalUsersServiceTypeKey.self] = newValue
        }
    }
}

protocol ExternalUsersServiceType {
    func getRegisteredExternalUser(on request: Request, user: OAuthUser) -> EventLoopFuture<(User?, ExternalUser?)>
    func getRedirectLocation(authClient: AuthClient) throws -> String
    func getOauthRequest(authClient: AuthClient, code: String) -> OAuthRequest
}

final class ExternalUsersService: ExternalUsersServiceType {

    public func getRegisteredExternalUser(on request: Request, user: OAuthUser) -> EventLoopFuture<(User?, ExternalUser?)> {
        return ExternalUser.query(on: request.db).with(\.$user).filter(\.$externalId == user.uniqueId).first().flatMap { externalUser in
            
            if let externalUser = externalUser {
                return request.success((externalUser.user, externalUser))
            }
            
            let emailNormalized = user.email.uppercased()
            return User.query(on: request.db).filter(\.$emailNormalized == emailNormalized).first().map { user in
                if let user = user {
                    return (user, nil)
                }
                
                return (nil, nil)
            }
        }
    }
    
    public func getRedirectLocation(authClient: AuthClient) throws -> String {
        switch authClient.type {
        case .apple:
            return try self.createAppleUrl(uri: authClient.uri, clientId: authClient.clientId)
        case .google:
            return try self.createGoogleUrl(uri: authClient.uri, clientId: authClient.clientId)
        case .microsoft:
            return try self.createMicrosoftUrl(uri: authClient.uri, tenantId: authClient.tenantId, clientId: authClient.clientId)
        }
    }
    
    public func getOauthRequest(authClient: AuthClient, code: String) -> OAuthRequest {
        switch authClient.type {
        case .apple:
            return self.getAppleOauthRequest(uri: authClient.uri,
                                             clientId: authClient.clientId,
                                             clientSecret: authClient.clientSecret,
                                             code: code)
        case .google:
            return self.getGoogleOauthRequest(uri: authClient.uri,
                                              clientId: authClient.clientId,
                                              clientSecret: authClient.clientSecret,
                                              code: code)
        case .microsoft:
            return self.getMicrosoftOauthRequest(uri: authClient.uri,
                                                 tenantId: authClient.tenantId ?? "",
                                                 clientId: authClient.clientId,
                                                 clientSecret: authClient.clientSecret,
                                                 code: code)
        }
    }
    
    private func createAppleUrl(uri: String, clientId: String) throws -> String {
        let host = "https://accounts.google.com/o/oauth2/v2/auth"
        
        let urlEncoder = URLEncodedFormEncoder()
        let scope = try urlEncoder.encode("openid profile email")
        let responseType = try urlEncoder.encode("code")
        let clientId = try urlEncoder.encode(clientId)
        let redirectUri = try urlEncoder.encode("http://localhost:8080/identity/callback/\(uri)")
        let state = try urlEncoder.encode("abcd")
        let nonce = try urlEncoder.encode("asd23sad")
        
        let location = "\(host)?" +
            "scope=\(scope)" +
            "&response_type=\(responseType)" +
            "&client_id=\(clientId)" +
            "&redirect_uri=\(redirectUri)" +
            "&state=\(state)" +
            "&nonce=\(nonce)"
        
        return location
    }
        
    private func createGoogleUrl(uri: String, clientId: String) throws -> String {
        let host = "https://accounts.google.com/o/oauth2/v2/auth"
        
        let urlEncoder = URLEncodedFormEncoder()
        let scope = try urlEncoder.encode("openid profile email")
        let responseType = try urlEncoder.encode("code")
        let clientId = try urlEncoder.encode(clientId)
        let redirectUri = try urlEncoder.encode("http://localhost:8080/identity/callback/\(uri)")
        let state = try urlEncoder.encode("abcd")
        let nonce = try urlEncoder.encode("asd23sad")
        
        let location = "\(host)?" +
            "scope=\(scope)" +
            "&response_type=\(responseType)" +
            "&client_id=\(clientId)" +
            "&redirect_uri=\(redirectUri)" +
            "&state=\(state)" +
            "&nonce=\(nonce)"
        
        return location
    }

    private func createMicrosoftUrl(uri: String, tenantId: String?, clientId: String) throws -> String {
        let host = "https://login.microsoftonline.com/\(tenantId ?? "unknown")/oauth2/v2.0/authorize"
        
        let urlEncoder = URLEncodedFormEncoder()
        let scope = try urlEncoder.encode("openid%20profile%20email")
        let responseType = try urlEncoder.encode("code")
        let clientId = try urlEncoder.encode(clientId)
        let redirectUri = try urlEncoder.encode("http://localhost:8080/identity/callback/\(uri)")
        let state = try urlEncoder.encode("abcd")
        let nonce = try urlEncoder.encode("asd23sad")
        
        let location = "\(host)?" +
            "scope=\(scope)" +
            "&response_type=\(responseType)" +
            "&client_id=\(clientId)" +
            "&redirect_uri=\(redirectUri)" +
            "&state=\(state)" +
            "&nonce=\(nonce)"
        
        return location
    }
    
    private func getAppleOauthRequest(uri: String, clientId: String, clientSecret: String, code: String) -> OAuthRequest {
        let oauthRequest = OAuthRequest(url: "https://oauth2.googleapis.com/token",
                                        code: code,
                                        clientId: clientId,
                                        clientSecret: clientSecret,
                                        redirectUri: "http://localhost:8080/identity/callback/\(uri)",
                                        grantType: "authorization_code")
        
        return oauthRequest
    }

    private func getGoogleOauthRequest(uri: String, clientId: String, clientSecret: String, code: String) -> OAuthRequest {
        let oauthRequest = OAuthRequest(url: "https://oauth2.googleapis.com/token",
                                        code: code,
                                        clientId: clientId,
                                        clientSecret: clientSecret,
                                        redirectUri: "http://localhost:8080/identity/callback/\(uri)",
                                        grantType: "authorization_code")
        
        return oauthRequest
    }

    private func getMicrosoftOauthRequest(uri: String, tenantId: String, clientId: String, clientSecret: String, code: String) -> OAuthRequest {
        let oauthRequest = OAuthRequest(url: "https://login.microsoftonline.com/\(tenantId)/oauth2/v2.0/token",
                                        code: code,
                                        clientId: clientId,
                                        clientSecret: clientSecret,
                                        redirectUri: "http://localhost:8080/identity/callback/\(uri)",
                                        grantType: "authorization_code")
        
        return oauthRequest
    }
}
