import Vapor

struct UserAuthenticator: BearerAuthenticator {
    typealias User = UserPayload
    
    func authenticate(bearer: BearerAuthorization, for request: Request) -> EventLoopFuture<User?> {
        do {
            let authorizationPayload = try request.jwt.verify(bearer.token, as: UserPayload.self)
            return request.success(authorizationPayload)
        } catch {
            return request.success(nil)
        }
   }
}
