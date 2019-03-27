@testable import App
import XCTest
import Vapor
import XCTest
import FluentPostgreSQL

final class LoginActionTests: XCTestCase {

    func testUserWithCorrectCredentialsShouldBeSignedInByUsername() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "nickfury",
                            email: "nickfury@testemail.com",
                            name: "Nick Fury")
        let loginRequestDto = LoginRequestDto(userNameOrEmail: "nickfury", password: "p@ssword")

        // Act.
        let response = try SharedApplication.application()
            .sendRequest(to: "/account/login", method: .POST, body: loginRequestDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.ok, "Response http status code should be ok (200).")
        let accessTokenDto = try response.content.decode(AccessTokenDto.self).wait()
        XCTAssert(accessTokenDto.accessToken.count > 0, "Access token should be returned for correct credentials")
        XCTAssert(accessTokenDto.refreshToken.count > 0, "Refresh token should be returned for correct credentials")
    }

    func testUserWithCorrectCredentialsShouldBeSignedInByEmail() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "stevenfury",
                            email: "stevenfury@testemail.com",
                            name: "Steven Fury")
        let loginRequestDto = LoginRequestDto(userNameOrEmail: "stevenfury@testemail.com", password: "p@ssword")

        // Act.
        let response = try SharedApplication.application()
            .sendRequest(to: "/account/login", method: .POST, body: loginRequestDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.ok, "Response http status code should be ok (200).")
        let accessTokenDto = try response.content.decode(AccessTokenDto.self).wait()
        XCTAssert(accessTokenDto.accessToken.count > 0, "Access token should be returned for correct credentials")
        XCTAssert(accessTokenDto.refreshToken.count > 0, "Refresh token should be returned for correct credentials")
    }

    func testUserWithIncorrectPasswordShouldNotBeSignedIn() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "martafury",
                            email: "martafury@testemail.com",
                            name: "Marta Fury")
        let loginRequestDto = LoginRequestDto(userNameOrEmail: "martafury", password: "incorrect")

        // Act.
        let response = try SharedApplication.application()
            .sendRequest(to: "/account/login", method: .POST, body: loginRequestDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (403).")
    }

    func testUserWithNotConfirmedAccountShouldNotBeSignedIn() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "josefury",
                            email: "josefury@testemail.com",
                            name: "Jose Fury",
                            emailWasConfirmed: false
        )
        let loginRequestDto = LoginRequestDto(userNameOrEmail: "josefury", password: "p@ssword")

        // Act.
        let response = try SharedApplication.application()
            .sendRequest(to: "/account/login", method: .POST, body: loginRequestDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (403).")
    }

    func testUserWithBlockedAccountShouldNotBeSignedIn() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "tomfury",
                            email: "tomfury@testemail.com",
                            name: "Tom Fury",
                            isBlocked: true
        )
        let loginRequestDto = LoginRequestDto(userNameOrEmail: "tomfury", password: "p@ssword")

        // Act.
        let response = try SharedApplication.application()
            .sendRequest(to: "/account/login", method: .POST, body: loginRequestDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (403).")
    }

    static let allTests = [
        ("testUserWithCorrectCredentialsShouldBeSignedInByUsername", testUserWithCorrectCredentialsShouldBeSignedInByUsername),
        ("testUserWithCorrectCredentialsShouldBeSignedInByEmail", testUserWithCorrectCredentialsShouldBeSignedInByEmail),
        ("testUserWithIncorrectPasswordShouldNotBeSignedIn", testUserWithIncorrectPasswordShouldNotBeSignedIn),
        ("testUserWithNotConfirmedAccountShouldNotBeSignedIn", testUserWithNotConfirmedAccountShouldNotBeSignedIn),
        ("testUserWithBlockedAccountShouldNotBeSignedIn", testUserWithBlockedAccountShouldNotBeSignedIn)
    ]
}
