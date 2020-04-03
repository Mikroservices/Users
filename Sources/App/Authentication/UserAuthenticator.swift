import Vapor

struct UserAuthenticator: BearerAuthenticator {
    typealias User = AuthorizationPayload
    
    func authenticate(bearer: BearerAuthorization, for request: Request) -> EventLoopFuture<User?> {
        do {
            let authorizationPayload = try request.jwt.verify(bearer.token, as: AuthorizationPayload.self)
            return request.eventLoop.makeSucceededFuture(authorizationPayload)
        } catch {
            return request.eventLoop.makeSucceededFuture(nil)
        }
   }
}
