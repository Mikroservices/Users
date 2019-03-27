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
        XCTAssertEqual(response.http.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (403).")
    }

    func testForgotPasswordTokenShouldNotBeGEneratedIfUserIsBlocked() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "wikired",
                            email: "wikired@testemail.com",
                            name: "Wiki Red",
                            isBlocked: true)
        let forgotPasswordRequestDto = ForgotPasswordRequestDto(email: "wikired@testemail.com")

        // Act.
        let response = try SharedApplication.application()
            .sendRequest(to: "/forgot/token", method: .POST, body: forgotPasswordRequestDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (403).")
    }

    static let allTests = [
        ("testForgotPasswordTokenShouldBeGeneratedForActiveUser", testForgotPasswordTokenShouldBeGeneratedForActiveUser),
        ("testForgotPasswordTokenShouldNotBeGeneratedIfEmailNotExists", testForgotPasswordTokenShouldNotBeGeneratedIfEmailNotExists),
        ("testForgotPasswordTokenShouldNotBeGEneratedIfUserIsBlocked", testForgotPasswordTokenShouldNotBeGEneratedIfUserIsBlocked)
    ]
}
