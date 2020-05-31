import Vapor
import Fluent

extension Application.Services {
    struct AuthenticationClientsServiceKey: StorageKey {
        typealias Value = AuthenticationClientsServiceType
    }

    var authenticationClientsService: AuthenticationClientsServiceType {
        get {
            self.application.storage[AuthenticationClientsServiceKey.self] ?? AuthenticationClientsService()
        }
        nonmutating set {
            self.application.storage[AuthenticationClientsServiceKey.self] = newValue
        }
    }
}

protocol AuthenticationClientsServiceType {
    func validateUri(on request: Request, uri: String, authClientId: UUID?) -> EventLoopFuture<Void>
}

final class AuthenticationClientsService: AuthenticationClientsServiceType {
    
    func validateUri(on request: Request, uri: String, authClientId: UUID?) -> EventLoopFuture<Void> {
        if let unwrapedAuthClientId = authClientId {
            return AuthClient.query(on: request.db).group(.and) { verifyUriGroup in
                verifyUriGroup.filter(\.$uri == uri)
                verifyUriGroup.filter(\.$id != unwrapedAuthClientId)
            }.first().flatMap { authClient -> EventLoopFuture<Void> in
                if authClient != nil {
                    return request.fail(AuthClientError.authClientWithUriExists)
                }
                
                return request.success()
            }
        } else {
            return AuthClient.query(on: request.db).filter(\.$uri == uri).first().flatMap { authClient -> EventLoopFuture<Void> in
                if authClient != nil {
                    return request.fail(AuthClientError.authClientWithUriExists)
                }
                
                return request.success()
            }
        }
    }
}
