import Foundation
import Vapor
import Fluent
import FluentPostgresDriver

extension Application.Services {
    struct UsersServiceKey: StorageKey {
        typealias Value = UsersServiceType
    }

    var usersService: UsersServiceType {
        get {
            self.application.storage[UsersServiceKey.self] ?? UsersService()
        }
        nonmutating set {
            self.application.storage[UsersServiceKey.self] = newValue
        }
    }
}

protocol UsersServiceType {
    func login(on request: Request, userNameOrEmail: String, password: String) throws -> EventLoopFuture<User>
    func forgotPassword(on request: Request, email: String) -> EventLoopFuture<User>
    func confirmForgotPassword(on request: Request, forgotPasswordGuid: String, password: String) -> EventLoopFuture<User>
    func changePassword(on request: Request, userId: UUID, currentPassword: String, newPassword: String) throws -> EventLoopFuture<User>
    func confirmEmail(on request: Request, userId: UUID, confirmationGuid: String) -> EventLoopFuture<User>
    func isUserNameTaken(on request: Request, userName: String) -> EventLoopFuture<Bool>
    func isEmailConnected(on request: Request, email: String) -> EventLoopFuture<Bool>
}

final class UsersService: UsersServiceType {

    func login(on request: Request, userNameOrEmail: String, password: String) throws -> EventLoopFuture<User> {

        let userNameOrEmailNormalized = userNameOrEmail.uppercased()

        return User.query(on: request.db).group(.or) { userNameGroup in
            userNameGroup.filter(\.$userNameNormalized == userNameOrEmailNormalized)
            userNameGroup.filter(\.$emailNormalized == userNameOrEmailNormalized)
        }.first().flatMapThrowing { userFromDb in

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

    func forgotPassword(on request: Request, email: String) -> EventLoopFuture<User> {
        let emailNormalized = email.uppercased()

        let userFuture = User.query(on: request.db).filter(\.$emailNormalized == emailNormalized).first()
        return userFuture.flatMap { userFromDb in

            guard let user = userFromDb else {
                return request.eventLoop.makeFailedFuture(EntityNotFoundError.userNotFound)
            }

            if user.isBlocked {
                return request.eventLoop.makeFailedFuture(ForgotPasswordError.userAccountIsBlocked)
            }

            user.forgotPasswordGuid = UUID.init().uuidString
            user.forgotPasswordDate = Date()

            return user.save(on: request.db).transform(to: user)
        }
    }

    func confirmForgotPassword(on request: Request, forgotPasswordGuid: String, password: String) -> EventLoopFuture<User> {
        let userFuture = User.query(on: request.db).filter(\.$forgotPasswordGuid == forgotPasswordGuid).first()
        return userFuture.flatMap { userFromDb in

            guard let user = userFromDb else {
                return request.eventLoop.makeFailedFuture(EntityNotFoundError.userNotFound)
            }

            if user.isBlocked {
                return request.eventLoop.makeFailedFuture(ForgotPasswordError.userAccountIsBlocked)
            }

            guard let forgotPasswordDate = user.forgotPasswordDate else {
                return request.eventLoop.makeFailedFuture(ForgotPasswordError.tokenNotGenerated)
            }

            let hoursDifference = Calendar.current.dateComponents([.hour], from: forgotPasswordDate, to: Date()).hour ?? 0
            if hoursDifference > 6 {
                return request.eventLoop.makeFailedFuture(ForgotPasswordError.tokenExpired)
            }
            
            user.forgotPasswordGuid = nil
            user.forgotPasswordDate = nil
            user.emailWasConfirmed = true
            
            do {
                user.salt = Password.generateSalt()
                user.password = try Password.hash(password, withSalt: user.salt)
            } catch {
                return request.eventLoop.makeFailedFuture(ForgotPasswordError.passwordNotHashed)
            }

            return user.save(on: request.db).transform(to: user)
        }
    }

    func changePassword(on request: Request, userId: UUID, currentPassword: String, newPassword: String) throws -> EventLoopFuture<User> {
        let userFuture = User.query(on: request.db).filter(\.$id == userId).first()
        return userFuture.flatMapThrowing { userFromDb in

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

            let salt = Password.generateSalt()
            let newPasswordHash = try Password.hash(newPassword, withSalt: salt)

            user.password = newPasswordHash
            user.salt = salt

            _ = user.update(on: request.db)
            return user
        }
    }

    func confirmEmail(on request: Request, userId: UUID, confirmationGuid: String) -> EventLoopFuture<User> {
        return User.find(userId, on: request.db).flatMap { userFromDb in

            guard let user = userFromDb else {
                return request.eventLoop.makeFailedFuture(RegisterError.invalidIdOrToken)
            }

            guard user.emailConfirmationGuid == confirmationGuid else {
                return request.eventLoop.makeFailedFuture(RegisterError.invalidIdOrToken)
            }

            user.emailWasConfirmed = true

            return user.save(on: request.db).transform(to: user)
        }
    }

    func isUserNameTaken(on request: Request, userName: String) -> EventLoopFuture<Bool> {

        let userNameNormalized = userName.uppercased()

        let userFuture = User.query(on: request.db).filter(\.$userNameNormalized == userNameNormalized).first()
        return userFuture.map { userFromDb in

            if userFromDb != nil {
                return true
            }

            return false
        }
    }

    func isEmailConnected(on request: Request, email: String) -> EventLoopFuture<Bool> {

        let emailNormalized = email.uppercased()

        let userFuture = User.query(on: request.db).filter(\.$emailNormalized == emailNormalized).first()
        return userFuture.map { userFromDb in

            if userFromDb != nil {
                return true
            }

            return false
        }
    }
}
