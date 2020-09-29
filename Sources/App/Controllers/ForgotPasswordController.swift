import Vapor

final class ForgotPasswordController: RouteCollection {

    public static let uri: PathComponent = .constant("forgot")
    
    func boot(routes: RoutesBuilder) throws {
        let forgotGroup = routes.grouped(ForgotPasswordController.uri)

        forgotGroup
            .grouped(EventHandlerMiddleware(.forgotToken))
            .post("token", use: forgotPasswordToken)
        
        forgotGroup
            .grouped(EventHandlerMiddleware(.forgotConfirm, storeRequest: false))
            .post("confirm", use: forgotPasswordConfirm)
    }

    /// Forgot password.
    func forgotPasswordToken(request: Request) throws -> EventLoopFuture<HTTPResponseStatus> {
        let forgotPasswordRequestDto = try request.content.decode(ForgotPasswordRequestDto.self)
        
        let usersService = request.application.services.usersService
        let emailsService = request.application.services.emailsService

        let updateUserFuture = usersService.forgotPassword(on: request, email: forgotPasswordRequestDto.email)

        let sendEmailFuture = updateUserFuture.flatMapThrowing { user in
            try emailsService.sendForgotPasswordEmail(on: request,
                                                      user: user,
                                                      redirectBaseUrl: forgotPasswordRequestDto.redirectBaseUrl)
        }

        return sendEmailFuture.transform(to: HTTPStatus.ok)
    }

    /// Changing password.
    func forgotPasswordConfirm(request: Request) throws -> EventLoopFuture<HTTPResponseStatus> {
        let confirmationDto = try request.content.decode(ForgotPasswordConfirmationRequestDto.self)
        try ForgotPasswordConfirmationRequestDto.validate(content: request)

        let usersService = request.application.services.usersService
        let confirmForgotPasswordFuture = usersService.confirmForgotPassword(
            on: request,
            forgotPasswordGuid: confirmationDto.forgotPasswordGuid,
            password: confirmationDto.password
        )

        return confirmForgotPasswordFuture.transform(to: HTTPStatus.ok)
    }
}
