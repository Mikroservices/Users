@testable import App
import Vapor
import FluentPostgreSQL

extension User {
    static func create(on application: Application,
                     userName: String,
                     email: String,
                     name: String,
                     password: String = "83427d87b9492b7e048a975025190efa55edb9948ae7ced5c6ccf1a553ce0e2b",
                     salt: String = "TNhZYL4F66KY7fUuqS/Juw==",
                     emailWasConfirmed: Bool = true,
                     isBlocked: Bool = false,
                     emailConfirmationGuid: String = "",
                     gravatarHash: String = "",
                     forgotPasswordGuid: String? = nil,
                     forgotPasswordDate: Date? = nil,
                     bio: String? = nil,
                     location: String? = nil,
                     website: String? = nil,
                     birthDate: Date? = nil) throws -> User {

        let connection = try application.newConnection(to: .psql).wait()
        let user = User(userName: userName,
                  email: email,
                  name: name,
                  password: password,
                  salt: salt,
                  emailWasConfirmed: emailWasConfirmed,
                  isBlocked: isBlocked,
                  emailConfirmationGuid: emailConfirmationGuid,
                  gravatarHash: gravatarHash,
                  forgotPasswordGuid: forgotPasswordGuid,
                  forgotPasswordDate: forgotPasswordDate,
                  bio: bio,
                  location: location,
                  website: website,
                  birthDate: birthDate)

        _ = try user.save(on: connection).wait()

        return user
    }

    static func get(on application: Application, userName: String) throws -> User {
        let connection = try application.newConnection(to: .psql).wait()
        guard let user = try User.query(on: connection).filter(\.userName == userName).first().wait() else {
            throw SharedApplicationError.unwrap
        }

        return user
    }

    func update(on application: Application) throws {
        let connection = try application.newConnection(to: .psql).wait()
        _ = try self.save(on: connection).wait()
    }

    func attach(role: Role, on application: Application) throws {
        let connection = try application.newConnection(to: .psql).wait()
        _ = try self.roles.attach(role, on: connection).wait()
    }

    func getRoles(on application: Application) throws -> [Role] {
        let connection = try application.newConnection(to: .psql).wait()
        return try self.roles.query(on: connection).all().wait()
    }
}
