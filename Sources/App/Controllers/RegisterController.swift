import Foundation
import Vapor
import JWT
import Crypto
import Recaptcha
import Fluent
import FluentPostgresDriver
import ExtendedError

final class RegisterController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        let registerGroup = routes.grouped("register")
        
        registerGroup.post(use: register)
        registerGroup.post("confirm", use: confirm)
        registerGroup.get("username", ":name", use: isUserNameTaken)
        registerGroup.get("email", ":email", use: isEmailConnected)
    }

    /// Register new user.
    func register(request: Request) throws -> EventLoopFuture<Response> {
        let registerUserDto = try request.content.decode(RegisterUserDto.self)
        
        try RegisterUserDto.validate(request)

        guard let captchaToken = registerUserDto.securityToken else {
            throw RegisterError.securityTokenIsMandatory
        }

        let captchaValidateFuture = try self.validateCaptcha(on: request, captchaToken: captchaToken)
        
        let validateUserNameFuture = captchaValidateFuture.flatMap {
            self.validateUserName(on: request, userName: registerUserDto.userName)
        }

        let validateEmailFuture = validateUserNameFuture.flatMap {
            self.validateEmail(on: request, email: registerUserDto.email)
        }

        let createUserFuture = validateEmailFuture.flatMapThrowing {
            try self.createUser(on: request, registerUserDto: registerUserDto)
        }.flatMap { user in user }

        let sendEmailFuture = createUserFuture.flatMapThrowing { user in
            try self.sendNewUserEmail(on: request, user: user)
        }.flatMap { user in user }

        return sendEmailFuture.flatMapThrowing { user in
            try self.createNewUserResponse(on: request, user: user)
        }
    }

    /// New account (email) confirmation.
    func confirm(request: Request) throws -> EventLoopFuture<HTTPResponseStatus> {
        let confirmEmailRequestDto = try request.content.decode(ConfirmEmailRequestDto.self)
        let usersService = request.application.services.usersService

        let confirmEmailFuture = try usersService.confirmEmail(on: request, 
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
            BooleanResponseDto(result)
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
            BooleanResponseDto(result)
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

    private func validateUserName(on request: Request, userName: String) -> EventLoopFuture<Void> {
        let userNameNormalized = userName.uppercased()
        return User.query(on: request.db).filter(\.$userNameNormalized == userNameNormalized).first().flatMap { user in
            if user != nil {
                return request.eventLoop.makeFailedFuture(RegisterError.userNameIsAlreadyTaken)
            }
            
            return request.eventLoop.makeSucceededFuture(())
        }
    }

    private func validateEmail(on request: Request, email: String?) -> EventLoopFuture<Void> {
        let emailNormalized = (email ?? "").uppercased()
        return User.query(on: request.db).filter(\.$emailNormalized == emailNormalized).first().flatMap { user in
            if user != nil {
                return request.eventLoop.makeFailedFuture(RegisterError.emailIsAlreadyConnected)
            }
            
            return request.eventLoop.makeSucceededFuture(())
        }
    }

    private func createUser(on request: Request, registerUserDto: RegisterUserDto) throws -> EventLoopFuture<User> {

        let salt = Password.generateSalt()
        let passwordHash = try Password.hash(registerUserDto.password, withSalt: salt)
        let emailConfirmationGuid = UUID.init().uuidString
        let gravatarHash = self.getGravatarHash(email: registerUserDto.email)
        
        let user = User(from: registerUserDto,
                        withPassword: passwordHash,
                        salt: salt,
                        emailConfirmationGuid: emailConfirmationGuid,
                        gravatarHash: gravatarHash)

        let saveUserFuture = user.save(on: request.db)
        let rolesWrappedFuture = saveUserFuture.map { _ in
            Role.query(on: request.db).filter(\.$isDefault == true).all()
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

    private func createNewUserResponse(on request: Request, user: User) throws -> Response {
        let createdUserDto = UserDto(from: user)
                
        let body = try Response.Body(data: JSONEncoder().encode(createdUserDto))
        let response = Response(status: .created, headers: HTTPHeaders(), body: body)
        response.headers.replaceOrAdd(name: .contentType, value: "application/json; charset=utf-8")
        response.headers.replaceOrAdd(name: .location, value: "\(UsersController.uri)/@\(user.userName)")
        
        return response
    }
    
    private func getGravatarHash(email: String) -> String {
        let gravatarEmail = email.lowercased().trimmingCharacters(in: [" "])

        if let gravatarEmailData = gravatarEmail.data(using: .utf8) {
            return Insecure.MD5.hash(data: gravatarEmailData).hexEncodedString()
        }
        
        return ""
    }
}

