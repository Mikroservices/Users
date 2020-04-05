@testable import App
import XCTVapor

final class MockEmailsService: EmailsServiceType {
    func sendForgotPasswordEmail(on request: Request, user: User) throws -> EventLoopFuture<Bool> {
        return request.eventLoop.makeSucceededFuture(true)
    }

    func sendConfirmAccountEmail(on request: Request, user: User) throws -> EventLoopFuture<Bool> {
        return request.eventLoop.makeSucceededFuture(true)
    }
}

