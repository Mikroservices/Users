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
        return try captchaService.validate(on: request, captchaFormResponse: captchaToken).map(to: Void.self) { success in

            if !success {
                throw RegisterError.securityTokenIsInvalid
            }

        }.flatMap(to: User?.self) { _ in
            let userNameNormalized = userDto.userName.uppercased()
            return User.query(on: request).filter(\.userNameNormalized == userNameNormalized).first()
        }.flatMap(to: User?.self) { user in

            if user != nil {
                throw RegisterError.userNameIsAlreadyTaken
            }

            let emailNormalized = (userDto.email ?? "").uppercased()
            return User.query(on: request).filter(\.emailNormalized == emailNormalized).first()
        }.flatMap(to: User.self) { user in

            if user != nil {
                throw RegisterError.emailIsAlreadyConnected
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
        }.flatMap(to: UserDto.self) { user in

            let settingsService = try request.make(SettingsService.self)
            return try settingsService.get(on: request).map(to: Void.self) { configuration in
                let emailsService = try request.make(EmailsService.self)
                _ = try emailsService.sendConfirmAccountEmail(on: request, configuration: configuration, user: user)
            }.transform(to: UserDto(from: user))
        }
    }

    // New account (email) confirmation.
    func confirm(request: Request, confirmEmailRequestDto: ConfirmEmailRequestDto) throws -> Future<HTTPResponseStatus> {
        let usersService = try request.make(UsersService.self)

        return try usersService.confirmEmail(on: request, userId: confirmEmailRequestDto.id, confirmationGuid: confirmEmailRequestDto.confirmationGuid)
        .transform(to: HTTPStatus.ok)
    }

    // User name verification.
    func isUserNameTaken(request: Request) throws -> Future<BooleanResponseDto> {

        let userName = try request.parameters.next(String.self)
        let usersService = try request.make(UsersService.self)

        return usersService.isUserNameTaken(on: request, userName: userName).map(to: BooleanResponseDto.self) { result in
            return BooleanResponseDto(result)
        }
    }

    // Email verification.
    func isEmailConnected(request: Request) throws -> Future<BooleanResponseDto> {

        let email = try request.parameters.next(String.self)
        let usersService = try request.make(UsersService.self)

        return usersService.isEmailConnected(on: request, email: email).map(to: BooleanResponseDto.self) { result in
            return BooleanResponseDto(result)
        }
    }
}
