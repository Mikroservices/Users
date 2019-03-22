//
//  MockEmailsService.swift
//  AppTests
//
//  Created by Marcin Czachurski on 22/03/2019.
//

@testable import App
import Foundation
import Vapor

final class MockEmailsService: EmailsServiceType {
    func sendForgotPasswordEmail(on request: Request, user: User) throws -> Future<Bool> {
        return request.future().map { return true }
    }

    func sendConfirmAccountEmail(on request: Request, user: User) throws -> Future<Bool> {
        return request.future().map { return true }
    }
}
