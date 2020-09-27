import Vapor

final class RegisterController: RouteCollection {

    public static let uri: PathComponent = .constant("register")
    
    func boot(routes: RoutesBuilder) throws {
        let registerGroup = routes.grouped(RegisterController.uri)
        
        registerGroup
            .grouped(EventHandlerMiddleware(.registerNewUser, storeRequest: false))
            .post(use: newUser)
        
        registerGroup
            .grouped(EventHandlerMiddleware(.registerConfirm))
            .post("confirm", use: confirm)
        
        registerGroup
            .grouped(EventHandlerMiddleware(.registerUserName))
            .get("username", ":name", use: isUserNameTaken)
        
        registerGroup
            .grouped(EventHandlerMiddleware(.registerEmail))
            .get("email", ":email", use: isEmailConnected)
    }

    /// Register new user.
    func newUser(request: Request) throws -> EventLoopFuture<Response> {
        let registerUserDto = try request.content.decode(RegisterUserDto.self)
        try RegisterUserDto.validate(content: request)

        guard let captchaToken = registerUserDto.securityToken else {
            throw RegisterError.securityTokenIsMandatory
        }

        let captchaValidateFuture = try self.validateCaptcha(on: request, captchaToken: captchaToken)
        
        let usersService = request.application.services.usersService

        let validateUserNameFuture = captchaValidateFuture.flatMap {
            usersService.validateUserName(on: request, userName: registerUserDto.userName)
        }

        let validateEmailFuture = validateUserNameFuture.flatMap {
            usersService.validateEmail(on: request, email: registerUserDto.email)
        }

        let createUserFuture = validateEmailFuture.flatMapThrowing {
            try self.createUser(on: request, registerUserDto: registerUserDto)
        }.flatMap { user in user }

        let sendEmailFuture = createUserFuture.flatMapThrowing { user in
            try self.sendNewUserEmail(on: request, user: user)
        }.flatMap { user in user }

        return sendEmailFuture.flatMap { user in
            self.createNewUserResponse(on: request, user: user)
        }
    }

    /// New account (email) confirmation.
    func confirm(request: Request) throws -> EventLoopFuture<HTTPResponseStatus> {
        let confirmEmailRequestDto = try request.content.decode(ConfirmEmailRequestDto.self)
        let usersService = request.application.services.usersService

        let confirmEmailFuture = usersService.confirmEmail(on: request,
                                                           userId: confirmEmailRequestDto.id,
                                                           confirmationGuid: confirmEmailRequestDto.confirmationGuid)

        return confirmEmailFuture.transform(to: HTTPStatus.ok)
    }

    /// User name verification.
    func isUserNameTaken(request: Request) throws -> EventLoopFuture<BooleanResponseDto> {

        guard let userName = request.parameters.get("name") else {
            throw Abort(.badRequest)
        }
        
        let usersService = request.application.services.usersService
        let isUserNameTakenFuture = usersService.isUserNameTaken(on: request, userName: userName)

        return isUserNameTakenFuture.map { result in
            BooleanResponseDto(result: result)
        }
    }

    /// Email verification.
    func isEmailConnected(request: Request) throws -> EventLoopFuture<BooleanResponseDto> {

        guard let email = request.parameters.get("email") else {
            throw Abort(.badRequest)
        }
        
        let usersService = request.application.services.usersService
        let isEmailConnectedFuture = usersService.isEmailConnected(on: request, email: email)

        return isEmailConnectedFuture.map { result in
            BooleanResponseDto(result: result)
        }
    }

    private func validateCaptcha(on request: Request, captchaToken: String) throws -> EventLoopFuture<Void> {
        let captchaService = request.application.services.captchaService
        return try captchaService.validate(on: request, captchaFormResponse: captchaToken).flatMapThrowing { success in
            if !success {
                throw RegisterError.securityTokenIsInvalid
            }
        }
    }

    private func createUser(on request: Request, registerUserDto: RegisterUserDto) throws -> EventLoopFuture<User> {

        let rolesService = request.application.services.rolesService
        let usersService = request.application.services.usersService
        
        let salt = Password.generateSalt()
        let passwordHash = try Password.hash(registerUserDto.password, withSalt: salt)
        let emailConfirmationGuid = UUID.init().uuidString
        let gravatarHash = usersService.createGravatarHash(from: registerUserDto.email)
        
        let user = User(from: registerUserDto,
                        withPassword: passwordHash,
                        salt: salt,
                        emailConfirmationGuid: emailConfirmationGuid,
                        gravatarHash: gravatarHash)

        let saveUserFuture = user.save(on: request.db)

        let rolesWrappedFuture = saveUserFuture.map { _ in
            rolesService.getDefault(on: request)
        }
        
        let rolesFuture = rolesWrappedFuture.flatMap { roles in
            roles
        }
        
        return rolesFuture.flatMap { roles -> EventLoopFuture<User> in
            var rolesSavedFuture: [EventLoopFuture<Void>] = [EventLoopFuture<Void>]()
            roles.forEach { role in
                let roleSavedFuture = user.$roles.attach(role, on: request.db)
                rolesSavedFuture.append(roleSavedFuture)
            }
            
            return EventLoopFuture.andAllSucceed(rolesSavedFuture, on: request.eventLoop).map { _ -> User in
                user
            }
        }
    }

    private func sendNewUserEmail(on request: Request, user: User) throws -> EventLoopFuture<User> {
        let emailsService = request.application.services.emailsService
        let sendEmailFuture = try emailsService.sendConfirmAccountEmail(on: request, user: user)
        return sendEmailFuture.transform(to: user)
    }

    private func createNewUserResponse(on request: Request, user: User) -> EventLoopFuture<Response> {
        let createdUserDto = UserDto(from: user)
        
        var headers = HTTPHeaders()
        headers.replaceOrAdd(name: .location, value: "/\(UsersController.uri)/@\(user.userName)")
        
        return createdUserDto.encodeResponse(status: .created, headers: headers, for: request)
    }
}

