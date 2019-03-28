@testable import App
import XCTest
import Vapor
import XCTest
import FluentPostgreSQL

final class ChangePasswordActionTests: XCTestCase {

    func testPasswordShouldBeChangedWhenAuthorizedUserChangePassword() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "markuswhite",
                            email: "markuswhite@testemail.com",
                            name: "Markus White")

        let changePasswordRequestDto = ChangePasswordRequestDto(currentPassword: "p@ssword", newPassword: "newP@ssword")

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "markuswhite", password: "p@ssword"),
            to: "/account/change-password",
            method: .POST, 
            body: changePasswordRequestDto
        )

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.ok, "Response http status code should be ok (200).")
        let newLoginRequestDto = LoginRequestDto(userNameOrEmail: "markuswhite", password: "newP@ssword")
        let newAccessTokenDto = try SharedApplication.application()
            .getResponse(to: "/account/login", method: .POST, data: newLoginRequestDto, decodeTo: AccessTokenDto.self)
        XCTAssert(newAccessTokenDto.accessToken.count > 0, "User should be signed in with new password.")
    }

    func testPasswordShouldNotBeChangedWhenNotAuthorizedUserTriesToChangePassword() throws {

        // Arrange.
        let changePasswordRequestDto = ChangePasswordRequestDto(currentPassword: "p@ssword", newPassword: "newP@ssword")

        // Act.
        let response = try SharedApplication.application()
            .sendRequest(to: "/account/change-password", method: .POST, body: changePasswordRequestDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.unauthorized, "Response http status code should be unauthorized (401).")
    }

    func testPasswordShouldNotBeChangedWhenAuthorizedUserEntersWrongOldPassword() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "annawhite",
                            email: "annawhite@testemail.com",
                            name: "Anna White")
        let changePasswordRequestDto = ChangePasswordRequestDto(currentPassword: "p@ssword-bad", newPassword: "newP@ssword")

        // Act.
        let errorResponse = try SharedApplication.application().getErrorResponse(
            as: .user(userName: "annawhite", password: "p@ssword"),
            to: "/account/change-password", 
            method: .POST,
            data: changePasswordRequestDto
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (400).")
        XCTAssertEqual(errorResponse.error.code, "invalidLoginCredentials", "Error code should be equal 'invalidLoginCredentials'.")
    }

    func testPasswordShouldNotBeChangedWhenUserAccountIsBlocked() throws {

        // Arrange.
        let user = try User.create(on: SharedApplication.application(),
                            userName: "willwhite",
                            email: "willwhite@testemail.com",
                            name: "Will White")
        let loginRequestDto = LoginRequestDto(userNameOrEmail: "willwhite", password: "p@ssword")
        let accessTokenDto = try SharedApplication.application()
            .getResponse(to: "/account/login", method: .POST, data: loginRequestDto, decodeTo: AccessTokenDto.self)
        user.isBlocked = true
        try user.update(on: SharedApplication.application())
        let headers: HTTPHeaders = [ HTTPHeaderName.authorization.description: "Bearer \(accessTokenDto.accessToken)" ]
        let changePasswordRequestDto = ChangePasswordRequestDto(currentPassword: "p@ssword", newPassword: "newP@ssword")

        // Act.
        let errorResponse = try SharedApplication.application().getErrorResponse(
            to: "/account/change-password",
            method: .POST,
            headers: headers,
            data: changePasswordRequestDto
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (400).")
        XCTAssertEqual(errorResponse.error.code, "userAccountIsBlocked", "Error code should be equal 'userAccountIsBlocked'.")
    }

    func testValidationErrorShouldBeReturnedWhenPasswordIsTooShort() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "timwhite",
                            email: "timwhite@testemail.com",
                            name: "Tim White")
        let changePasswordRequestDto = ChangePasswordRequestDto(currentPassword: "p@ssword", newPassword: "1234567")

        // Act.
        let errorResponse = try SharedApplication.application().getErrorResponse(
            as: .user(userName: "timwhite", password: "p@ssword"),
            to: "/account/change-password",
            method: .POST,
            data: changePasswordRequestDto
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (400).")
        XCTAssertEqual(errorResponse.error.code, "validationError", "Error code should be equal 'validationError'.")
        XCTAssertEqual(errorResponse.error.reason, "'newPassword' is less than required minimum of 8 characters and 'newPassword' is not a valid password", "Error reason should be correct.")
    }

    func testValidationErrorShouldBeReturnedWhenPasswordIsTooLong() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "robinwhite",
                            email: "robinwhite@testemail.com",
                            name: "Robin White")
        let changePasswordRequestDto = ChangePasswordRequestDto(currentPassword: "p@ssword", newPassword: "123456789012345678901234567890123")

        // Act.
        let errorResponse = try SharedApplication.application().getErrorResponse(
            as: .user(userName: "robinwhite", password: "p@ssword"),
            to: "/account/change-password",
            method: .POST,
            data: changePasswordRequestDto
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (400).")
        XCTAssertEqual(errorResponse.error.code, "validationError", "Error code should be equal 'userAccountIsBlocked'.")
        XCTAssertEqual(errorResponse.error.reason, "'newPassword' is greater than required maximum of 32 characters and 'newPassword' is not a valid password", "Error reason should be correct.")
    }

    static let allTests = [
        ("testPasswordShouldBeChangedWhenAuthorizedUserChangePassword", testPasswordShouldBeChangedWhenAuthorizedUserChangePassword),
        ("testPasswordShouldNotBeChangedWhenNotAuthorizedUserTriesToChangePassword", testPasswordShouldNotBeChangedWhenNotAuthorizedUserTriesToChangePassword),
        ("testPasswordShouldNotBeChangedWhenAuthorizedUserEntersWrongOldPassword", testPasswordShouldNotBeChangedWhenAuthorizedUserEntersWrongOldPassword),
        ("testPasswordShouldNotBeChangedWhenUserAccountIsBlocked", testPasswordShouldNotBeChangedWhenUserAccountIsBlocked),
        ("testValidationErrorShouldBeReturnedWhenPasswordIsTooShort", testValidationErrorShouldBeReturnedWhenPasswordIsTooShort),
        ("testValidationErrorShouldBeReturnedWhenPasswordIsTooLong", testValidationErrorShouldBeReturnedWhenPasswordIsTooLong)
    ]
}
