//
//  EmailsService.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 20/03/2019.
//

import Foundation
import Vapor
import FluentPostgreSQL

final class EmailsService: ServiceType {
    static func makeService(for container: Container) throws -> EmailsService {
        return EmailsService()
    }

    func sendForgotPasswordEmail(on request: Request, configuration: Configuration, user: User) throws -> Future<Response> {
        guard let emailServiceAddress = configuration.getString(.emailServiceAddress) else {
            throw Abort(.internalServerError, reason: "Email service is not configured in database.")
        }

        guard let forgotPasswordGuid = user.forgotPasswordGuid else {
            throw ForgotPasswordError.tokenNotGenerated
        }

        let userName = user.getUserName()

        let client = try request.client()
        return client.post("\(emailServiceAddress)/emails") { httpRequest in
            let emailAddress = EmailAddressDto(address: user.email, name: user.name)
            let email = EmailDto(to: emailAddress,
                                 title: "Letterer - Forgot password",
                                 body: "<html><body><div>Hi \(userName),</div><div>You can reset your password by clicking following <a href='https://letterer.me/reset-password?token=\(forgotPasswordGuid)'>link</a>.</div></body></html>")

            try httpRequest.content.encode(email)
        }
    }

    func sendConfirmAccountEmail(on request: Request, configuration: Configuration, user: User) throws -> Future<Response> {
        guard let emailServiceAddress = configuration.getString(.emailServiceAddress) else {
            throw Abort(.internalServerError, reason: "Email service is not configured in database.")
        }

        guard let userId = user.id else {
            throw RegisterError.userIdNotExists
        }

        let userName = user.getUserName()

        let client = try request.client()
        return client.post("\(emailServiceAddress)/emails") { httpRequest in
            let emailAddress = EmailAddressDto(address: user.email, name: user.name)
            let email = EmailDto(to: emailAddress,
                                 title: "Letterer - Confirm email",
                                 body: "<html><body><div>Hi \(userName),</div><div>Please confirm your account by clicking following <a href='https://letterer.me/confirm-email?token=\(user.emailConfirmationGuid)&user=\(userId)'>link</a>.</div></body></html>")

            try httpRequest.content.encode(email)
        }
    }
}
