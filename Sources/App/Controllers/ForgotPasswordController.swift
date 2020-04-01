import Foundation
import Vapor
import JWT
import Crypto
import Recaptcha
import Fluent
import FluentPostgresDriver


final class ForgotPasswordController: RouteCollection {

    public static let uri = "/forgot"

    func boot(routes: RoutesBuilder) throws {
        // routes.post(ForgotPasswordRequestDto.self, at: "\(ForgotPasswordController.uri)/token", use: forgotPasswordToken)
        // routes.post(ForgotPasswordConfirmationRequestDto.self, at: "\(ForgotPasswordController.uri)/confirm", use: forgotPasswordConfirm)
    }

    /*
    /// Forgot password.
    func forgotPasswordToken(request: Request, forgotPasswordRequestDto: ForgotPasswordRequestDto) throws -> EventLoopFuture<HTTPResponseStatus> {

        let usersService = request.application.services.usersService
        let emailsService = request.application.services.emailsService

        let updateUserFuture = try usersService.forgotPassword(on: request, email: forgotPasswordRequestDto.email)

        let sendEmailFuture = updateUserFuture.flatMapThrowing { user in
            try emailsService.sendForgotPasswordEmail(on: request, user: user)
        }

        return sendEmailFuture.transform(to: HTTPStatus.ok)
    }

    /// Changing password.
    func forgotPasswordConfirm(request: Request, confirmationDto: ForgotPasswordConfirmationRequestDto) throws -> EventLoopFuture<HTTPResponseStatus> {

        try ForgotPasswordConfirmationRequestDto.validate(request)

        let usersService = request.application.services.usersService
        let confirmForgotPasswordFuture = try usersService.confirmForgotPassword(
            on: request,
            forgotPasswordGuid: confirmationDto.forgotPasswordGuid,
            password: confirmationDto.password
        )

        return confirmForgotPasswordFuture.transform(to: HTTPStatus.ok)
    }
 */
}
