//
//  UsersController.swift
//  App
//
//  Created by Marcin Czachurski on 25/10/2018.
//

import Foundation
import Vapor
import JWT
import FluentSQLite

/// Controls basic operations for User object.
final class UsersController: RouteCollection {

    func boot(router: Router) throws {
        router.post(SignInRequestDto.self, at: "/users/login", use: login)
        router.post(UserDto.self, at: "/users", use: register)
    }

    // Register new user.
    func register(req: Request, userDto: UserDto) throws -> Future<UserDto> {

        guard let password = userDto.password else {
            throw Abort(.badRequest, reason: "Password is required.")
        }

        let savedUser = User.query(on: req).filter(\.email == userDto.email).first().flatMap(to: User.self) { user in

            if user != nil {
                throw Abort(.badRequest, reason: "User with email '\(userDto.email)' exists.")
            }

            let salt = try Password.generateSalt()
            let passwordHash = try Password.hash(password, withSalt: salt)
            let emailConfirmationGuid = UUID.init().uuidString

            let user = User(
                email: userDto.email,
                name: userDto.name,
                password: passwordHash,
                salt: salt,
                emailWasConfirmed: false,
                isBlocked: false,
                emailConfirmationGuid: emailConfirmationGuid
            )

            return user.save(on: req)

        }.map(to: UserDto.self) { user in
            return UserDto(id: user.id, email: user.email, name: user.name, password: nil)
        }

        return savedUser
    }

    /// Sign-in user.
    func login(req: Request, signInRequestDto: SignInRequestDto) throws -> Future<SignInResponseDto> {
        return User.query(on: req).filter(\.email == signInRequestDto.email).first().map(to: SignInResponseDto.self) { userFromDb in

            guard let user = userFromDb else {
                throw Abort(.unauthorized, reason: "Invalid email or password.")
            }

            let passwordHash = try Password.hash(signInRequestDto.password, withSalt: user.salt)
            if user.password != passwordHash {
                throw Abort(.unauthorized, reason: "Invalid email or password.")
            }

            if !user.emailWasConfirmed {
                throw Abort(.unauthorized, reason: "User email was not confirmed.")
            }

            if user.isBlocked {
                throw Abort(.unauthorized, reason: "User account is blocked.")
            }

            // Create payload.
            let expirationDate = Date().addingTimeInterval(TimeInterval(3600.0))
            let authorizationPayload = AuthorizationPayload(
                id: user.id,
                name: user.name,
                email: user.email,
                exp: expirationDate
            )

            // Create JWT and sign
            let secureKeyStorage = try req.make(SecureKeyStorage.self)
            let data = try JWT(payload: authorizationPayload).sign(using: .hs256(key: secureKeyStorage.secureKey))
            let actionToken = String(data: data, encoding: .utf8) ?? ""

            return SignInResponseDto(actionToken)
        }
    }
}
