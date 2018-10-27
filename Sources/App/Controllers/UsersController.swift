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
final class UsersController {

    /// Returns a list of all Users.
    func index(_ req: Request) throws -> Future<[User]> {
        return User.query(on: req).all()
    }

    func create(_ req: Request) throws -> Future<UserDto> {
        let futureSavedUser = try req.content.decode(UserDto.self).flatMap(to: User.self) { userDto in

            guard let password = userDto.password else {
                throw Abort(.badRequest, reason: "Password is required.")
            }

            return User.query(on: req).filter(\.email == userDto.email).first().flatMap(to: User.self) { user in

                if user != nil {
                    throw Abort(.badRequest, reason: "User with email '\(userDto.email)' exists.")
                }

                let user = User(email: userDto.email, userName: userDto.userName, password: password)
                return user.save(on: req)
            }
        }

        let userDtoResponse = futureSavedUser.map(to: UserDto.self) { user in
            return UserDto(id: user.id, email: user.email, userName: user.userName, password: nil)
        }

        return userDtoResponse
    }

    func call(user: User?) -> Void {

    }

    /// Sign-in user.
    func signIn(_ req: Request) throws -> Future<SignInResponseDto> {
        return try req.content.decode(SignInRequestDto.self).flatMap(to: SignInResponseDto.self) { signInRequestDto in

            return User.query(on: req).filter(\.email == signInRequestDto.email).first().map(to: SignInResponseDto.self) { user in

                guard let userFromDb = user else {
                    throw Abort(.badRequest, reason: "Invalid email or password")
                }

                // Create payload.
                let expirationDate = Date().addingTimeInterval(TimeInterval(3600.0))
                let authorizationPayload = AuthorizationPayload(id: userFromDb.id, name: userFromDb.userName, exp: expirationDate)

                // Create JWT and sign
                let data = try JWT(payload: authorizationPayload).sign(using: .hs256(key: "secret"))
                let actionToken = String(data: data, encoding: .utf8) ?? ""

                return SignInResponseDto(actionToken)
            }
        }
    }
}
