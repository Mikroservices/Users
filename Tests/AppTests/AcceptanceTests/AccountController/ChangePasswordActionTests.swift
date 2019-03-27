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

    func testUnauthorizationStatusCodeShouldBeReturnedWhenNotAuthorizedUserTriesToChangePassword() throws {

        // Arrange.
        let changePasswordRequestDto = ChangePasswordRequestDto(currentPassword: "p@ssword", newPassword: "newP@ssword")

        // Act.
        let response = try SharedApplication.application()
            .sendRequest(to: "/account/change-password", method: .POST, body: changePasswordRequestDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.unauthorized, "Response http status code should be unauthorized (401).")
    }

    func testBadRequestStatusCodeShouldBeReturnedWhenAuthorizedUserEntersWrongOldPassword() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "annawhite",
                            email: "annawhite@testemail.com",
                            name: "Anna White")
        let changePasswordRequestDto = ChangePasswordRequestDto(currentPassword: "p@ssword-bad", newPassword: "newP@ssword")

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "annawhite", password: "p@ssword"),
            to: "/account/change-password", 
            method: .POST,
            body: changePasswordRequestDto
        )

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (403).")
    }

    func testBadRequestStatusCodeShouldBeReturnedWhenUserAccountIsBlocked() throws {

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
        let response = try SharedApplication.application()
            .sendRequest(to: "/account/change-password", method: .POST, headers: headers, body: changePasswordRequestDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (403).")
    }

    func testBadRequestStatusCodeShouldBeReturnedWhenPasswordIsTooShort() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "timwhite",
                            email: "timwhite@testemail.com",
                            name: "Tim White")
        let changePasswordRequestDto = ChangePasswordRequestDto(currentPassword: "p@ssword", newPassword: "1234567")

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "timwhite", password: "p@ssword"),
            to: "/account/change-password",
            method: .POST,
            body: changePasswordRequestDto
        )

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (403).")
    }

    func testBadRequestStatusCodeShouldBeReturnedWhenPasswordIsTooLong() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "robinwhite",
                            email: "robinwhite@testemail.com",
                            name: "Robin White")
        let changePasswordRequestDto = ChangePasswordRequestDto(currentPassword: "p@ssword", newPassword: "123456789012345678901234567890123")

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "robinwhite", password: "p@ssword"),
            to: "/account/change-password",
            method: .POST,
            body: changePasswordRequestDto
        )

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (403).")
    }

    static let allTests = [
        ("testPasswordShouldBeChangedWhenAuthorizedUserChangePassword", testPasswordShouldBeChangedWhenAuthorizedUserChangePassword),
        ("testUnauthorizationStatusCodeShouldBeReturnedWhenNotAuthorizedUserTriesToChangePassword", testUnauthorizationStatusCodeShouldBeReturnedWhenNotAuthorizedUserTriesToChangePassword),
        ("testBadRequestStatusCodeShouldBeReturnedWhenAuthorizedUserEntersWrongOldPassword", testBadRequestStatusCodeShouldBeReturnedWhenAuthorizedUserEntersWrongOldPassword),
        ("testBadRequestStatusCodeShouldBeReturnedWhenUserAccountIsBlocked", testBadRequestStatusCodeShouldBeReturnedWhenUserAccountIsBlocked),
        ("testBadRequestStatusCodeShouldBeReturnedWhenPasswordIsTooShort", testBadRequestStatusCodeShouldBeReturnedWhenPasswordIsTooShort),
        ("testBadRequestStatusCodeShouldBeReturnedWhenPasswordIsTooLong", testBadRequestStatusCodeShouldBeReturnedWhenPasswordIsTooLong)
    ]
}
