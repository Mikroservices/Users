@testable import App
import XCTest
import Vapor
import JWT
import Crypto
import XCTest

/*
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

    func testAccessTokenShouldContainsBasicInformationAboutUser() throws {

        // Arrange.
        let user = try User.create(on: SharedApplication.application(),
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
        let jwtPrivateKey = try Setting.get(on: SharedApplication.application(), key: .jwtPrivateKey)
        let rsaKey: RSAKey = try .private(pem: jwtPrivateKey.value)
        let authorizationPayload = try JWT<AuthorizationPayload>(from: accessTokenDto.accessToken, verifiedUsing: JWTSigner.rs512(key: rsaKey))
        XCTAssertEqual(authorizationPayload.payload.email, user.email, "Email should be included in JWT access token")
        XCTAssertEqual(authorizationPayload.payload.id, user.id, "User id should be included in JWT access token")
        XCTAssertEqual(authorizationPayload.payload.name, user.name, "Name should be included in JWT access token")
        XCTAssertEqual(authorizationPayload.payload.userName, user.userName, "User name should be included in JWT access token")
        XCTAssertEqual(authorizationPayload.payload.gravatarHash, user.gravatarHash, "Gravatar hash should be included in JWT access token")
    }

    func testAccessTokenShouldContainsInformationAboutUserRoles() throws {

        // Arrange.
        let user = try User.create(on: SharedApplication.application(),
                                   userName: "yokofury",
                                   email: "yokofury@testemail.com",
                                   name: "Yoko Fury")
        let role = try Role.get(on: SharedApplication.application(), name: "Administrator")
        try user.attach(role: role, on: SharedApplication.application())
        let loginRequestDto = LoginRequestDto(userNameOrEmail: "yokofury@testemail.com", password: "p@ssword")

        // Act.
        let response = try SharedApplication.application()
            .sendRequest(to: "/account/login", method: .POST, body: loginRequestDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.ok, "Response http status code should be ok (200).")
        let accessTokenDto = try response.content.decode(AccessTokenDto.self).wait()
        let jwtPrivateKey = try Setting.get(on: SharedApplication.application(), key: .jwtPrivateKey)
        let rsaKey: RSAKey = try .private(pem: jwtPrivateKey.value)
        let authorizationPayload = try JWT<AuthorizationPayload>(from: accessTokenDto.accessToken, verifiedUsing: JWTSigner.rs512(key: rsaKey))
        XCTAssertEqual(authorizationPayload.payload.roles[0], "administrator", "User roles should be included in JWT access token")
    }

    func testUserWithIncorrectPasswordShouldNotBeSignedIn() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "martafury",
                            email: "martafury@testemail.com",
                            name: "Marta Fury")
        let loginRequestDto = LoginRequestDto(userNameOrEmail: "martafury", password: "incorrect")

        // Act.
        let errorResponse = try SharedApplication.application().getErrorResponse(
            to: "/account/login",
            method: .POST,
            data: loginRequestDto
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (400).")
        XCTAssertEqual(errorResponse.error.code, "invalidLoginCredentials", "Error code should be equal 'invalidLoginCredentials'.")
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
        let errorResponse = try SharedApplication.application().getErrorResponse(
            to: "/account/login",
            method: .POST,
            data: loginRequestDto
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (400).")
        XCTAssertEqual(errorResponse.error.code, "emailNotConfirmed", "Error code should be equal 'emailNotConfirmed'.")
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
        let errorResponse = try SharedApplication.application().getErrorResponse(
            to: "/account/login",
            method: .POST,
            data: loginRequestDto
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (400).")
        XCTAssertEqual(errorResponse.error.code, "userAccountIsBlocked", "Error code should be equal 'userAccountIsBlocked'.")
    }

    static let allTests = [
        ("testUserWithCorrectCredentialsShouldBeSignedInByUsername", testUserWithCorrectCredentialsShouldBeSignedInByUsername),
        ("testUserWithCorrectCredentialsShouldBeSignedInByEmail", testUserWithCorrectCredentialsShouldBeSignedInByEmail),
        ("testUserWithIncorrectPasswordShouldNotBeSignedIn", testUserWithIncorrectPasswordShouldNotBeSignedIn),
        ("testUserWithNotConfirmedAccountShouldNotBeSignedIn", testUserWithNotConfirmedAccountShouldNotBeSignedIn),
        ("testUserWithBlockedAccountShouldNotBeSignedIn", testUserWithBlockedAccountShouldNotBeSignedIn)
    ]
}
*/
