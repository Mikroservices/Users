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

        let userNameNormalized = try request.parameters.next(String.self).uppercased().replacingOccurrences(of: "@", with: "")

        return User.query(on: request).filter(\.userNameNormalized == userNameNormalized).first().map(to: UserDto.self) { userFromDb in

            guard let user = userFromDb else {
                throw UserError.userNotExists
            }

            let userDto = UserDto(from: user)

            let authorizationService = try request.make(AuthorizationService.self)
            let userNameFromToken = try authorizationService.getUserNameFromBearerToken(request: request)
            let isProfileOwner = userNameFromToken == userNameNormalized

            if !isProfileOwner {
                userDto.email = ""
            }

            return userDto
        }
    }

    func update(request: Request, userDto: UserDto) throws -> Future<UserDto> {

        let authorizationService = try request.make(AuthorizationService.self)
        guard let userNameFromToken = try authorizationService.getUserNameFromBearerToken(request: request) else {
            throw Abort(.unauthorized)
        }

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
        }.map(to: UserDto.self) { user in
            let userDto = UserDto(from: user)
            return userDto
        }
    }

    func delete(request: Request) throws -> Future<HTTPStatus> {

        let authorizationService = try request.make(AuthorizationService.self)
        guard let userNameFromToken = try authorizationService.getUserNameFromBearerToken(request: request) else {
            throw Abort(.unauthorized)
        }

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
        }.transform(to: HTTPStatus.ok)
    }
}
