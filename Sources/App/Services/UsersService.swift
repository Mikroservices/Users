//
//  UsersService.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 20/03/2019.
//

import Foundation
import Vapor
import FluentPostgreSQL

protocol UsersServiceType: Service {
    func login(on request: Request, userNameOrEmail: String, password: String) throws -> Future<User>
    func forgotPassword(on request: Request, email: String) throws -> Future<User>
    func confirmForgotPassword(on request: Request, forgotPasswordGuid: String, password: String) throws -> Future<User>
    func changePassword(on request: Request, userName: String, currentPassword: String, newPassword: String) throws -> Future<User>
    func confirmEmail(on request: Request, userId: UUID, confirmationGuid: String) throws -> Future<User>
    func isUserNameTaken(on request: Request, userName: String) -> Future<Bool>
    func isEmailConnected(on request: Request, email: String) -> Future<Bool>
}

final class UsersService: UsersServiceType {

    func login(on request: Request, userNameOrEmail: String, password: String) throws -> Future<User> {

        let userNameOrEmailNormalized = userNameOrEmail.uppercased()

        return User.query(on: request).group(.or) { userNameGroup in
            userNameGroup.filter(\.userNameNormalized == userNameOrEmailNormalized)
            userNameGroup.filter(\.emailNormalized == userNameOrEmailNormalized)
        }.first().map(to: User.self) { userFromDb in

            guard let user = userFromDb else {
                throw LoginError.invalidLoginCredentials
            }

            let passwordHash = try Password.hash(password, withSalt: user.salt)
            if user.password != passwordHash {
                throw LoginError.invalidLoginCredentials
            }

            if !user.emailWasConfirmed {
                throw LoginError.emailNotConfirmed
            }

            if user.isBlocked {
                throw LoginError.userAccountIsBlocked
            }

            return user
        }
    }

    func forgotPassword(on request: Request, email: String) throws -> Future<User> {
        let emailNormalized = email.uppercased()

        return User.query(on: request).filter(\.emailNormalized == emailNormalized).first().flatMap(to: User.self) { userFromDb in

            guard let user = userFromDb else {
                throw ForgotPasswordError.userNotExists
            }

            if user.isBlocked {
                throw ForgotPasswordError.userAccountIsBlocked
            }

            user.forgotPasswordGuid = UUID.init().uuidString
            user.forgotPasswordDate = Date()

            return user.save(on: request)
        }
    }

    func confirmForgotPassword(on request: Request, forgotPasswordGuid: String, password: String) throws -> Future<User> {
        return User.query(on: request).filter(\.forgotPasswordGuid == forgotPasswordGuid).first().flatMap(to: User.self) { userFromDb in

            guard let user = userFromDb else {
                throw ForgotPasswordError.userNotExists
            }

            if user.isBlocked {
                throw ForgotPasswordError.userAccountIsBlocked
            }

            guard let forgotPasswordDate = user.forgotPasswordDate else {
                throw ForgotPasswordError.tokenExpired
            }

            let hoursDifference = Calendar.current.dateComponents([.minute], from: forgotPasswordDate, to: Date()).hour ?? 0
            if hoursDifference > 6 {
                throw ForgotPasswordError.tokenExpired
            }

            let salt = try Password.generateSalt()
            let passwordHash = try Password.hash(password, withSalt: salt)

            user.forgotPasswordGuid = nil
            user.forgotPasswordDate = nil
            user.password = passwordHash
            user.salt = salt
            user.emailWasConfirmed = true

            return user.save(on: request)
        }
    }

    func changePassword(on request: Request, userName: String, currentPassword: String, newPassword: String) throws -> Future<User> {

        let userNameNormalized = userName.uppercased()

        return User.query(on: request).filter(\.userNameNormalized == userNameNormalized).first().flatMap(to: User.self) { userFromDb in

            guard let user = userFromDb else {
                throw LoginError.invalidLoginCredentials
            }

            let currentPasswordHash = try Password.hash(currentPassword, withSalt: user.salt)
            if user.password != currentPasswordHash {
                throw LoginError.invalidLoginCredentials
            }

            if !user.emailWasConfirmed {
                throw LoginError.emailNotConfirmed
            }

            if user.isBlocked {
                throw LoginError.userAccountIsBlocked
            }

            let salt = try Password.generateSalt()
            let newPasswordHash = try Password.hash(newPassword, withSalt: salt)

            user.password = newPasswordHash
            user.salt = salt

            return user.update(on: request)
        }
    }

    func confirmEmail(on request: Request, userId: UUID, confirmationGuid: String) throws -> Future<User> {
        return User.find(userId, on: request).flatMap(to: User.self) { userFromDb in

            guard let user = userFromDb else {
                throw RegisterError.invalidIdOrToken
            }

            guard user.emailConfirmationGuid == confirmationGuid else {
                throw RegisterError.invalidIdOrToken
            }

            user.emailWasConfirmed = true
            return user.save(on: request)
        }
    }

    func isUserNameTaken(on request: Request, userName: String) -> Future<Bool> {

        let userNameNormalized = userName.uppercased()

        return User.query(on: request).filter(\.userNameNormalized == userNameNormalized).first().map(to: Bool.self) { userFromDb in

            if userFromDb != nil {
                return true
            }

            return false
        }
    }

    func isEmailConnected(on request: Request, email: String) -> Future<Bool> {

        let emailNormalized = email.uppercased()

        return User.query(on: request).filter(\.emailNormalized == emailNormalized).first().map(to: Bool.self) { userFromDb in

            if userFromDb != nil {
                return true
            }

            return false
        }
    }
}
