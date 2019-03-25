//
//  User.swift
//  Users/Letterer
//
//  Created by Marcin Czachurski on 24/03/2019.
//

@testable import App
import Vapor
import FluentPostgreSQL

extension User {
    static func create(on application: Application,
                     userName: String,
                     email: String,
                     name: String,
                     password: String = "",
                     salt: String = "",
                     emailWasConfirmed: Bool = true,
                     isBlocked: Bool = false,
                     emailConfirmationGuid: String = "",
                     gravatarHash: String = "") throws -> User {

        let connection = try application.newConnection(to: .psql).wait()
        let user = User(userName: userName,
                  email: email,
                  name: name,
                  password: password,
                  salt: salt,
                  emailWasConfirmed: emailWasConfirmed,
                  isBlocked: isBlocked,
                  emailConfirmationGuid: emailConfirmationGuid,
                  gravatarHash: gravatarHash)

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
}
