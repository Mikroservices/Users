//
//  ChangePasswordActionTests.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 25/03/2019.
//

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
                            name: "Markus White",
                            password: "83427d87b9492b7e048a975025190efa55edb9948ae7ced5c6ccf1a553ce0e2b",
                            salt: "TNhZYL4F66KY7fUuqS/Juw==")
        let loginRequestDto = LoginRequestDto(userNameOrEmail: "markuswhite", password: "p@ssword")
        let accessTokenDto = try SharedApplication.application()
            .getResponse(to: "/account/login", method: .POST, data: loginRequestDto, decodeTo: AccessTokenDto.self)
        let headers: HTTPHeaders = [ HTTPHeaderName.authorization.description: "Bearer \(accessTokenDto.accessToken)" ]
        let changePasswordRequestDto = ChangePasswordRequestDto(currentPassword: "p@ssword", newPassword: "newP@ssword")

        // Act.
        let response = try SharedApplication.application()
            .sendRequest(to: "/account/change-password", method: .POST, headers: headers, body: changePasswordRequestDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.ok, "Response http status code should be ok (200).")
        let newLoginRequestDto = LoginRequestDto(userNameOrEmail: "markuswhite", password: "newP@ssword")
        let newAccessTokenDto = try SharedApplication.application()
            .getResponse(to: "/account/login", method: .POST, data: loginRequestDto, decodeTo: AccessTokenDto.self)
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
                            name: "Anna White",
                            password: "83427d87b9492b7e048a975025190efa55edb9948ae7ced5c6ccf1a553ce0e2b",
                            salt: "TNhZYL4F66KY7fUuqS/Juw==")
        let loginRequestDto = LoginRequestDto(userNameOrEmail: "annawhite", password: "p@ssword")
        let accessTokenDto = try SharedApplication.application()
            .getResponse(to: "/account/login", method: .POST, data: loginRequestDto, decodeTo: AccessTokenDto.self)
        let headers: HTTPHeaders = [ HTTPHeaderName.authorization.description: "Bearer \(accessTokenDto.accessToken)" ]
        let changePasswordRequestDto = ChangePasswordRequestDto(currentPassword: "p@ssword-bad", newPassword: "newP@ssword")

        // Act.
        let response = try SharedApplication.application()
            .sendRequest(to: "/account/change-password", method: .POST, headers: headers, body: changePasswordRequestDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (403).")
    }

    func testBadRequestStatusCodeShouldBeReturnedWhenUserAccountIsNotConfirmed() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "henrywhite",
                            email: "henrywhite@testemail.com",
                            name: "Henry White",
                            password: "83427d87b9492b7e048a975025190efa55edb9948ae7ced5c6ccf1a553ce0e2b",
                            salt: "TNhZYL4F66KY7fUuqS/Juw==",
                            emailWasConfirmed: false)
        let loginRequestDto = LoginRequestDto(userNameOrEmail: "henrywhite", password: "p@ssword")
        let accessTokenDto = try SharedApplication.application()
            .getResponse(to: "/account/login", method: .POST, data: loginRequestDto, decodeTo: AccessTokenDto.self)
        let headers: HTTPHeaders = [ HTTPHeaderName.authorization.description: "Bearer \(accessTokenDto.accessToken)" ]
        let changePasswordRequestDto = ChangePasswordRequestDto(currentPassword: "p@ssword", newPassword: "newP@ssword")

        // Act.
        let response = try SharedApplication.application()
            .sendRequest(to: "/account/change-password", method: .POST, headers: headers, body: changePasswordRequestDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (403).")
    }

    func testBadRequestStatusCodeShouldBeReturnedWhenUserAccountIsBlocked() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "willwhite",
                            email: "willwhite@testemail.com",
                            name: "Will White",
                            password: "83427d87b9492b7e048a975025190efa55edb9948ae7ced5c6ccf1a553ce0e2b",
                            salt: "TNhZYL4F66KY7fUuqS/Juw==",
                            isBlocked: true)
        let loginRequestDto = LoginRequestDto(userNameOrEmail: "willwhite", password: "p@ssword")
        let accessTokenDto = try SharedApplication.application()
            .getResponse(to: "/account/login", method: .POST, data: loginRequestDto, decodeTo: AccessTokenDto.self)
        let headers: HTTPHeaders = [ HTTPHeaderName.authorization.description: "Bearer \(accessTokenDto.accessToken)" ]
        let changePasswordRequestDto = ChangePasswordRequestDto(currentPassword: "p@ssword", newPassword: "newP@ssword")

        // Act.
        let response = try SharedApplication.application()
            .sendRequest(to: "/account/change-password", method: .POST, headers: headers, body: changePasswordRequestDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (403).")
    }

    static let allTests = [
        ("testPasswordShouldBeChangedWhenAuthorizedUserChangePassword", testPasswordShouldBeChangedWhenAuthorizedUserChangePassword),
        ("testUnauthorizationStatusCodeShouldBeReturnedWhenNotAuthorizedUserTriesToChangePassword", testUnauthorizationStatusCodeShouldBeReturnedWhenNotAuthorizedUserTriesToChangePassword),
        ("testBadRequestStatusCodeShouldBeReturnedWhenAuthorizedUserEntersWrongOldPassword", testBadRequestStatusCodeShouldBeReturnedWhenAuthorizedUserEntersWrongOldPassword),
        ("testBadRequestStatusCodeShouldBeReturnedWhenUserAccountIsNotConfirmed", testBadRequestStatusCodeShouldBeReturnedWhenUserAccountIsNotConfirmed),
        ("testBadRequestStatusCodeShouldBeReturnedWhenUserAccountIsBlocked", testBadRequestStatusCodeShouldBeReturnedWhenUserAccountIsBlocked)
    ]
}