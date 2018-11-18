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

        let captcha = try request.make(Captcha.self)
        return try captcha.validate(captchaFormResponse: captchaToken).map(to: Void.self) { success in

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
            let client = try request.client()
            let settingsStorage = try request.make(SettingsStorage.self)

            guard let userId = user.id else {
                throw RegisterError.userIdNotExists
            }

            let userName = user.getUserName()

            return client.post("\(settingsStorage.emailServiceAddress)/emails") { httpRequest in
                let emailAddress = EmailAddressDto(address: user.email, name: user.name)
                let email = EmailDto(to: emailAddress,
                                     title: "Letterer - Confirm email",
                                     body: "<html><body><div>Hi \(userName),</div><div>Please confirm your account by clicking following <a href='https://letterer.me/confirm-email?token=\(user.emailConfirmationGuid)&user=\(userId)'>link</a>.</div></body></html>")

                try httpRequest.content.encode(email)
                }.map(to: UserDto.self) { _ in
                    return UserDto(from: user)
            }
        }
    }

    /// Confirm email address.
    func confirm(request: Request, confirmEmailRequestDto: ConfirmEmailRequestDto) throws -> Future<HTTPResponseStatus> {
        return User.find(confirmEmailRequestDto.id, on: request).flatMap(to: User.self) { userFromDb in

            guard let user = userFromDb else {
                throw RegisterError.invalidIdOrToken
            }

            guard user.emailConfirmationGuid == confirmEmailRequestDto.confirmationGuid else {
                throw RegisterError.invalidIdOrToken
            }

            user.emailWasConfirmed = true
            return user.save(on: request)
        }.transform(to: HTTPStatus.ok)
    }

    func isUserNameTaken(request: Request) throws -> Future<BooleanResponseDto> {

        let userNameNormalized = try request.parameters.next(String.self).uppercased()

        return User.query(on: request).filter(\.userNameNormalized == userNameNormalized).first().map(to: BooleanResponseDto.self) { userFromDb in

            if userFromDb != nil {
                return BooleanResponseDto(true)
            }

            return BooleanResponseDto(false)
        }
    }

    func isEmailConnected(request: Request) throws -> Future<BooleanResponseDto> {

        let emailNormalized = try request.parameters.next(String.self).uppercased()

        return User.query(on: request).filter(\.emailNormalized == emailNormalized).first().map(to: BooleanResponseDto.self) { userFromDb in

            if userFromDb != nil {
                return BooleanResponseDto(true)
            }

            return BooleanResponseDto(false)
        }
    }
}