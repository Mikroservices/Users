import Foundation
import Vapor
import JWT

struct GuardIsSuperUserMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        guard let authorizationPayload = request.auth.get(UserPayload.self) else {
            return request.eventLoop.makeFailedFuture(Abort(.unauthorized))
        }
        
        guard authorizationPayload.isSuperUser else {
            return request.eventLoop.makeFailedFuture(Abort(.forbidden))
        }
        
        return next.respond(to: request)
    }
}
