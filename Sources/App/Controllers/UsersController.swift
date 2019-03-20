//
//  UsersController.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 25/10/2018.
//

import Vapor
import FluentPostgreSQL

/// Controls basic operations for User object.
final class UsersController: RouteCollection {

    func boot(router: Router) throws {
        router.get("/users", String.parameter, use: profile)
        router.put(UserDto.self, at: "/users", String.parameter, use: update)
        router.delete("/users", String.parameter, use: delete)
    }

    /// User profile.
    func profile(request: Request) throws -> Future<UserDto> {

        let authorizationService = try request.make(AuthorizationService.self)
        let userNameNormalized = try request.parameters.next(String.self).uppercased().replacingOccurrences(of: "@", with: "")

        let userFuture = User.query(on: request).filter(\.userNameNormalized == userNameNormalized).first()
        let userNameFromTokenFuture = try authorizationService.getUserNameFromBearerToken(request: request)

        return map(to: UserDto.self, userFuture, userNameFromTokenFuture) { userFromDb, userNameFromToken in
            guard let user = userFromDb else {
                throw UserError.userNotExists
            }

            let userDto = UserDto(from: user)

            let isProfileOwner = userNameFromToken?.uppercased() == userNameNormalized
            if !isProfileOwner {
                userDto.email = nil
            }

            return userDto
        }
    }

    // Update user data.
    func update(request: Request, userDto: UserDto) throws -> Future<UserDto> {

        let authorizationService = try request.make(AuthorizationService.self)
        return try authorizationService.getUserNameFromBearerToken(request: request).map(to: String.self) { userNameFromToken in
            guard let unwrapedUserNameFromToken = userNameFromToken else {
                throw Abort(.unauthorized)
            }

            return unwrapedUserNameFromToken
        }.flatMap(to: User.self) { userNameFromToken in
            let userNameNormalized = try request.parameters.next(String.self).uppercased().replacingOccurrences(of: "@", with: "")

            return User.query(on: request).filter(\.userNameNormalized == userNameNormalized).first().flatMap(to: User.self) { userFromDb in

                guard let user = userFromDb else {
                    throw UserError.userNotExists
                }

                let isProfileOwner = userNameFromToken.uppercased() == userNameNormalized
                guard isProfileOwner else {
                    throw UserError.someoneElseProfile
                }

                user.name = userDto.name
                user.bio = userDto.bio
                user.birthDate = userDto.birthDate
                user.location = userDto.location
                user.website = userDto.website

                return user.update(on: request)
            }
        }.map(to: UserDto.self) { user in
            let userDto = UserDto(from: user)
            return userDto
        }
    }

    // Delete user.
    func delete(request: Request) throws -> Future<HTTPStatus> {

        let authorizationService = try request.make(AuthorizationService.self)

        return try authorizationService.getUserNameFromBearerToken(request: request).map(to: String.self) { userNameFromToken in
            guard let unwrapedUserNameFromToken = userNameFromToken else {
                throw Abort(.unauthorized)
            }

            return unwrapedUserNameFromToken
        }.flatMap(to: Void.self) { userNameFromToken in
            let userNameNormalized = try request.parameters.next(String.self).uppercased().replacingOccurrences(of: "@", with: "")

            return User.query(on: request).filter(\.userNameNormalized == userNameNormalized).first().flatMap(to: Void.self) { userFromDb in

                guard let user = userFromDb else {
                    throw UserError.userNotExists
                }

                let isProfileOwner = userNameFromToken.uppercased() == userNameNormalized
                guard isProfileOwner else {
                    throw UserError.someoneElseProfile
                }

                return user.delete(on: request)
            }
        }.transform(to: HTTPStatus.ok)
    }
}
