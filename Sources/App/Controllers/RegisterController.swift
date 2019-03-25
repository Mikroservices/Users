//
//  RegisterController.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 25/10/2018.
//

import Foundation
import Vapor
import JWT
import Crypto
import Recaptcha
import FluentPostgreSQL

final class RegisterController: RouteCollection {

    public static let uri = "/register"

    func boot(router: Router) throws {
        router.post(UserDto.self, at: RegisterController.uri, use: register)
        router.post(ConfirmEmailRequestDto.self, at: "\(RegisterController.uri)/confirm", use: confirm)
        router.get("\(RegisterController.uri)/userName", String.parameter, use: isUserNameTaken)
        router.get("\(RegisterController.uri)/email", String.parameter, use: isEmailConnected)
    }

    /// Register new user.
    func register(request: Request, userDto: UserDto) throws -> Future<Response> {

        try userDto.validate()

        guard let captchaToken = userDto.securityToken else {
            throw RegisterError.securityTokenIsMandatory
        }

        let captchaValidateFuture = try self.validateCaptcha(on: request, captchaToken: captchaToken)
        
        let validateUserNameFuture = captchaValidateFuture.flatMap {
            try self.validateUserName(on: request, userName: userDto.userName)
        }

        let validateEmailFuture = validateUserNameFuture.flatMap {
            try self.validateEmail(on: request, email: userDto.email)
        }

        let createUserFuture = validateEmailFuture.flatMap {
            try self.createUser(on: request, userDto: userDto)
        }

        let sendEmailFuture = createUserFuture.flatMap { user in
            try self.sendNewUserEmail(on: request, user: user)
        }

        return sendEmailFuture.flatMap { user in
            try self.createNewUserResponse(on: request, user: user)
        }
    }

    /// New account (email) confirmation.
    func confirm(request: Request, confirmEmailRequestDto: ConfirmEmailRequestDto) throws -> Future<HTTPResponseStatus> {
        let usersService = try request.make(UsersServiceType.self)

        let confirmEmailFuture = try usersService.confirmEmail(on: request, 
                                                               userId: confirmEmailRequestDto.id,
                                                               confirmationGuid: confirmEmailRequestDto.confirmationGuid)

        return confirmEmailFuture.transform(to: HTTPStatus.ok)
    }

    /// User name verification.
    func isUserNameTaken(request: Request) throws -> Future<BooleanResponseDto> {

        let userName = try request.parameters.next(String.self)
        let usersService = try request.make(UsersServiceType.self)

        let isUserNameTakenFuture = usersService.isUserNameTaken(on: request, userName: userName)

        return isUserNameTakenFuture.map { result in
            BooleanResponseDto(result)
        }
    }

    /// Email verification.
    func isEmailConnected(request: Request) throws -> Future<BooleanResponseDto> {

        let email = try request.parameters.next(String.self)
        let usersService = try request.make(UsersServiceType.self)

        let isEmailConnectedFuture = usersService.isEmailConnected(on: request, email: email)

        return isEmailConnectedFuture.map { result in
            BooleanResponseDto(result)
        }
    }

    private func validateCaptcha(on request: Request, captchaToken: String) throws -> Future<Void> {
        let captchaService = try request.make(CaptchaServiceType.self)
        return try captchaService.validate(on: request, captchaFormResponse: captchaToken).map { success in
            if !success {
                throw RegisterError.securityTokenIsInvalid
            }
        }
    }

    private func validateUserName(on request: Request, userName: String) throws -> Future<Void> {
        let userNameNormalized = userName.uppercased()
        return User.query(on: request).filter(\.userNameNormalized == userNameNormalized).first().map { user in
            if user != nil {
                throw RegisterError.userNameIsAlreadyTaken
            }
        }
    }

    private func validateEmail(on request: Request, email: String?) throws -> Future<Void> {
        let emailNormalized = (email ?? "").uppercased()
        return User.query(on: request).filter(\.emailNormalized == emailNormalized).first().map { user in
            if user != nil {
                throw RegisterError.emailIsAlreadyConnected
            }
        }
    }

    private func createUser(on request: Request, userDto: UserDto) throws -> Future<User> {

        guard let password = userDto.password else {
            throw RegisterError.passwordIsRequired
        }

        let salt = try Password.generateSalt()
        let passwordHash = try Password.hash(password, withSalt: salt)
        let emailConfirmationGuid = UUID.init().uuidString

        let gravatarEmail = (userDto.email ?? "").lowercased().trimmingCharacters(in: [" "])
        let gravatarHash = try MD5.hash(gravatarEmail).hexEncodedString()

        let user = User(from: userDto,
                        withPassword: passwordHash,
                        salt: salt,
                        emailConfirmationGuid: emailConfirmationGuid,
                        gravatarHash: gravatarHash)

        return user.save(on: request)
    }

    private func sendNewUserEmail(on request: Request, user: User) throws -> Future<User> {
        let emailsService = try request.make(EmailsServiceType.self)
        let sendEmailFuture = try emailsService.sendConfirmAccountEmail(on: request, user: user)
        return sendEmailFuture.transform(to: user)
    }

    private func createNewUserResponse(on request: Request, user: User) throws -> Future<Response> {
        let createdUserDto = UserDto(from: user)
        return try createdUserDto.encode(for: request).map { response in
            response.http.headers.replaceOrAdd(name: .location, value: "\(UsersController.uri)/\(user.id?.uuidString ?? "")")
            response.http.status = .created

            return response
        }
    }
}

