//
//  ConfirmActionTests.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 24/03/2019.
//

@testable import App
import XCTest
import Vapor
import XCTest
import FluentPostgreSQL

final class ConfirmActionTests: XCTestCase {

    func testAccountShouldBeConfirmedWithCorrectConfirmationGuid() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "samanthasmith",
                            email: "samanthasmith@testemail.com",
                            name: "Samantha Smith",
                            emailWasConfirmed: false)
        let user = try User.get(on: SharedApplication.application(), userName: "samanthasmith")
        let confirmEmailRequestDto = ConfirmEmailRequestDto(id: user.id!, confirmationGuid: user.emailConfirmationGuid)

        // Act.
        let response = try SharedApplication.application().sendRequest(to: "/register/confirm", method: .POST, body: confirmEmailRequestDto)

        // Assert.
        let userAfterRequest = try User.get(on: SharedApplication.application(), userName: "samanthasmith")
        XCTAssertEqual(response.http.status, HTTPResponseStatus.ok, "Response http status code should be ok (200).")
        XCTAssertEqual(userAfterRequest.emailWasConfirmed, true, "Email is not confirmed.")
    }

    func testAccountShouldNotBeConfirmedWithIncorrectConfirmationGuid() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "eriksmith",
                            email: "eriksmith@testemail.com",
                            name: "Erik Smith",
                            emailWasConfirmed: false)
        let user = try User.get(on: SharedApplication.application(), userName: "eriksmith")
        let confirmEmailRequestDto = ConfirmEmailRequestDto(id: user.id!, confirmationGuid: UUID().uuidString)

        // Act.
        let response = try SharedApplication.application().sendRequest(to: "/register/confirm", method: .POST, body: confirmEmailRequestDto)

        // Assert.
        let userAfterRequest = try User.get(on: SharedApplication.application(), userName: "eriksmith")
        XCTAssertEqual(response.http.status, HTTPResponseStatus.badRequest, "Response http status code should be ok (200).")
        XCTAssertEqual(userAfterRequest.emailWasConfirmed, false, "Email is confirmed.")
    }

    static let allTests = [
        ("testAccountShouldBeConfirmedWithCorrectConfirmationGuid", testAccountShouldBeConfirmedWithCorrectConfirmationGuid),
        ("testAccountShouldNotBeConfirmedWithIncorrectConfirmationGuid", testAccountShouldNotBeConfirmedWithIncorrectConfirmationGuid)
    ]
}
