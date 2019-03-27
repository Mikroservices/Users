@testable import App
import Foundation
import XCTest
import Vapor
import XCTest
import FluentPostgreSQL

final class ForgotConfirmActionTests: XCTestCase {

    func testPasswordShouldBeChangeForCorrectToken() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "annapink",
                            email: "annapink@testemail.com",
                            name: "Anna Pink",
                            forgotPasswordGuid: "ANNAPINKGUID",
                            forgotPasswordDate: Date())
        let confirmationRequestDto = ForgotPasswordConfirmationRequestDto(forgotPasswordGuid: "ANNAPINKGUID", password: "newP@ssword")

        // Act.
        let response = try SharedApplication.application()
            .sendRequest(to: "/forgot/confirm", method: .POST, body: confirmationRequestDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.ok, "Response http status code should be ok (200).")
        let newLoginRequestDto = LoginRequestDto(userNameOrEmail: "annapink", password: "newP@ssword")
        let newAccessTokenDto = try SharedApplication.application()
            .getResponse(to: "/account/login", method: .POST, data: newLoginRequestDto, decodeTo: AccessTokenDto.self)
        XCTAssert(newAccessTokenDto.accessToken.count > 0, "User should be signed in with new password.")
    }

    func testPasswordShouldNotBeChangedForIncorrectToken() throws {

        // Arrange.
        let confirmationRequestDto = ForgotPasswordConfirmationRequestDto(forgotPasswordGuid: "NOTEXISTS", password: "newP@ssword")

        // Act.
        let response = try SharedApplication.application()
            .sendRequest(to: "/forgot/confirm", method: .POST, body: confirmationRequestDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.badRequest, "Response http status code should be ok (200).")
    }

    func testPasswordShouldNotBeChangedForBlockedUser() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "josephpink",
                            email: "josephpink@testemail.com",
                            name: "Joseph Pink",
                            isBlocked: true,
                            forgotPasswordGuid: "JOSEPHPINKGUID",
                            forgotPasswordDate: Date())
        let confirmationRequestDto = ForgotPasswordConfirmationRequestDto(forgotPasswordGuid: "NOTEXISTS", password: "newP@ssword")

        // Act.
        let response = try SharedApplication.application()
            .sendRequest(to: "/forgot/confirm", method: .POST, body: confirmationRequestDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.badRequest, "Response http status code should be ok (200).")
    }

    func testPasswordShouldNotBeChangedForOverdueToken() throws {

        // Arrange.
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)
        _ = try User.create(on: SharedApplication.application(),
                            userName: "mariapink",
                            email: "mariapink@testemail.com",
                            name: "Maria Pink",
                            forgotPasswordGuid: "JOSEPHPINKGUID",
                            forgotPasswordDate: yesterday)
        let confirmationRequestDto = ForgotPasswordConfirmationRequestDto(forgotPasswordGuid: "JOSEPHPINKGUID", password: "newP@ssword")

        // Act.
        let response = try SharedApplication.application()
            .sendRequest(to: "/forgot/confirm", method: .POST, body: confirmationRequestDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.badRequest, "Response http status code should be ok (200).")
    }

    func testPasswordShouldNotBeChangedWhenNewPasswordIsTooShort() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "tatianapink",
                            email: "tatianapink@testemail.com",
                            name: "Tatiana Pink",
                            forgotPasswordGuid: "TATIANAGUID",
                            forgotPasswordDate: Date())
        let confirmationRequestDto = ForgotPasswordConfirmationRequestDto(forgotPasswordGuid: "TATIANAGUID", password: "1234567")

        // Act.
        let response = try SharedApplication.application()
            .sendRequest(to: "/forgot/confirm", method: .POST, body: confirmationRequestDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.badRequest, "Response http status code should be ok (200).")
    }

    func testPasswordShouldNotBeChangedWhenPasswordIsTooLong() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "ewelinapink",
                            email: "ewelinapink@testemail.com",
                            name: "Ewelina Pink",
                            forgotPasswordGuid: "EWELINAGUID",
                            forgotPasswordDate: Date())
        let confirmationRequestDto = ForgotPasswordConfirmationRequestDto(forgotPasswordGuid: "EWELINAGUID", password: "123456789012345678901234567890123")

        // Act.
        let response = try SharedApplication.application()
            .sendRequest(to: "/forgot/confirm", method: .POST, body: confirmationRequestDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.badRequest, "Response http status code should be ok (200).")
    }

    static let allTests = [
        ("testPasswordShouldBeChangeForCorrectToken", testPasswordShouldBeChangeForCorrectToken),
        ("testPasswordShouldNotBeChangedForIncorrectToken", testPasswordShouldNotBeChangedForIncorrectToken),
        ("testPasswordShouldNotBeChangedForBlockedUser", testPasswordShouldNotBeChangedForBlockedUser),
        ("testPasswordShouldNotBeChangedForOverdueToken", testPasswordShouldNotBeChangedForOverdueToken),
        ("testPasswordShouldNotBeChangedWhenNewPasswordIsTooShort", testPasswordShouldNotBeChangedWhenNewPasswordIsTooShort),
        ("testPasswordShouldNotBeChangedWhenPasswordIsTooLong", testPasswordShouldNotBeChangedWhenPasswordIsTooLong)
    ]
}
