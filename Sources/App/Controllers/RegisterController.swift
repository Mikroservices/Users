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

    func boot(router: Router) throws {
        router.post(UserDto.self, at: "/register", use: register)
        router.post(ConfirmEmailRequestDto.self, at: "/register/confirm", use: confirm)
        router.get("/register/userName", String.parameter, use: isUserNameTaken)
        router.get("/register/email", String.parameter, use: isEmailConnected)
    }

    // Register new user.
    func register(request: Request, userDto: UserDto) throws -> Future<UserDto> {

        try userDto.validate()

        guard let captchaToken = userDto.securityToken else {
            throw RegisterError.securityTokenIsMandatory
        }

        guard let password = userDto.password else {
            throw RegisterError.passwordIsRequired
        }

        let captchaService = try request.make(CaptchaService.self)
        let captchaValidateFuture = try captchaService.validate(on: request, captchaFormResponse: captchaToken).map { success in
            if !success {
                throw RegisterError.securityTokenIsInvalid
            }
        }
        
        let validateUserNameFuture = captchaValidateFuture.flatMap(to: Void.self) { 
            let userNameNormalized = userDto.userName.uppercased()
            return User.query(on: request).filter(\.userNameNormalized == userNameNormalized).first().map { user in
                if user != nil {
                    throw RegisterError.userNameIsAlreadyTaken
                }
            }
        }

        let validateEmailFuture = validateUserNameFuture.flatMap(to: Void.self) { user in
            let emailNormalized = (userDto.email ?? "").uppercased()
            return User.query(on: request).filter(\.emailNormalized == emailNormalized).first().map { user in
                if user != nil {
                    throw RegisterError.emailIsAlreadyConnected
                }
            }
        }

        let createUserFuture = validateEmailFuture.flatMap(to: User.self) { user in

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

        let userDataFuture = createUserFuture.flatMap(to: UserDto.self) { user in
            let emailsService = try request.make(EmailsService.self)
            let sendEmailFuture = try emailsService.sendConfirmAccountEmail(on: request, user: user)
            return sendEmailFuture.transform(to: UserDto(from: user))
        }

        return userDataFuture
    }

    // New account (email) confirmation.
    func confirm(request: Request, confirmEmailRequestDto: ConfirmEmailRequestDto) throws -> Future<HTTPResponseStatus> {
        let usersService = try request.make(UsersService.self)

        let confirmEmailFuture = try usersService.confirmEmail(on: request, 
                                                               userId: confirmEmailRequestDto.id,
                                                               confirmationGuid: confirmEmailRequestDto.confirmationGuid)

        return confirmEmailFuture.transform(to: HTTPStatus.ok)
    }

    // User name verification.
    func isUserNameTaken(request: Request) throws -> Future<BooleanResponseDto> {

        let userName = try request.parameters.next(String.self)
        let usersService = try request.make(UsersService.self)

        let isUserNameTakenFuture = usersService.isUserNameTaken(on: request, userName: userName)

        return isUserNameTakenFuture.map(to: BooleanResponseDto.self) { result in
            return BooleanResponseDto(result)
        }
    }

    // Email verification.
    func isEmailConnected(request: Request) throws -> Future<BooleanResponseDto> {

        let email = try request.parameters.next(String.self)
        let usersService = try request.make(UsersService.self)

        let isEmailConnectedFuture = usersService.isEmailConnected(on: request, email: email)

        return isEmailConnectedFuture.map(to: BooleanResponseDto.self) { result in
            return BooleanResponseDto(result)
        }
    }
}
