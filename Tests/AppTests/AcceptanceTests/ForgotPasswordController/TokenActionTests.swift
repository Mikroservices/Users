@testable import App
import XCTest
import Vapor
import XCTest
import FluentPostgreSQL

final class TokenActionTests: XCTestCase {

    func testForgotPasswordTokenShouldBeGeneratedForActiveUser() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "johnred",
                            email: "johnred@testemail.com",
                            name: "John Red")
        let forgotPasswordRequestDto = ForgotPasswordRequestDto(email: "johnred@testemail.com")

        // Act.
        let response = try SharedApplication.application()
            .sendRequest(to: "/forgot/token", method: .POST, body: forgotPasswordRequestDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.ok, "Response http status code should be ok (200).")
    }

    func testForgotPasswordTokenShouldNotBeGeneratedIfEmailNotExists() throws {

        // Arrange.
        let forgotPasswordRequestDto = ForgotPasswordRequestDto(email: "not-exists@testemail.com")

        // Act.
        let response = try SharedApplication.application()
            .sendRequest(to: "/forgot/token", method: .POST, body: forgotPasswordRequestDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.notFound, "Response http status code should be not found (404).")
    }

    func testForgotPasswordTokenShouldNotBeGeneratedIfUserIsBlocked() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "wikired",
                            email: "wikired@testemail.com",
                            name: "Wiki Red",
                            isBlocked: true)
        let forgotPasswordRequestDto = ForgotPasswordRequestDto(email: "wikired@testemail.com")

        // Act.
        let errorResponse = try SharedApplication.application().getErrorResponse(
            to: "/forgot/token",
            method: .POST,
            data: forgotPasswordRequestDto
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (400).")
        XCTAssertEqual(errorResponse.error.code, "userAccountIsBlocked", "Error code should be equal 'userAccountIsBlocked'.")
    }

    static let allTests = [
        ("testForgotPasswordTokenShouldBeGeneratedForActiveUser", testForgotPasswordTokenShouldBeGeneratedForActiveUser),
        ("testForgotPasswordTokenShouldNotBeGeneratedIfEmailNotExists", testForgotPasswordTokenShouldNotBeGeneratedIfEmailNotExists),
        ("testForgotPasswordTokenShouldNotBeGeneratedIfUserIsBlocked", testForgotPasswordTokenShouldNotBeGeneratedIfUserIsBlocked)
    ]
}
