//
//  RefreshActionTests.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 25/03/2019.
//

@testable import App
import XCTest
import Vapor
import XCTest
import FluentPostgreSQL

final class RefreshActionTests: XCTestCase {

    func testNewTokensShouldBeReturnedWhenOldRefreshTokenIsValid() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "sandragreen",
                            email: "sandragreen@testemail.com",
                            name: "Sandra Green")
        let loginRequestDto = LoginRequestDto(userNameOrEmail: "sandragreen", password: "p@ssword")
        let accessTokenDto = try SharedApplication.application()
            .getResponse(to: "/account/login", method: .POST, data: loginRequestDto, decodeTo: AccessTokenDto.self)
        let refreshTokenDto = RefreshTokenDto(refreshToken: accessTokenDto.refreshToken)

        // Act.
        let newRefreshTokenDto = try SharedApplication.application()
            .getResponse(to: "/account/refresh", method: .POST, data: refreshTokenDto, decodeTo: AccessTokenDto.self)

        // Assert.
        XCTAssert(newRefreshTokenDto.refreshToken.count > 0, "New refresh token wasn't created.")
    }

    func testNewTokensShouldNotBeReturnedWhenOldRefreshTokenIsNotValid() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "johngreen",
                            email: "johngreen@testemail.com",
                            name: "John Green")
        let loginRequestDto = LoginRequestDto(userNameOrEmail: "johngreen", password: "p@ssword")
        let accessTokenDto = try SharedApplication.application()
            .getResponse(to: "/account/login", method: .POST, data: loginRequestDto, decodeTo: AccessTokenDto.self)
        let refreshTokenDto = RefreshTokenDto(refreshToken: "\(accessTokenDto.refreshToken)00")

        // Act.
        let response = try SharedApplication.application()
            .sendRequest(to: "/account/refresh", method: .POST, body: refreshTokenDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (403).")
    }

    func testNewTokensShouldNotBeReturnedWhenOldRefreshTokenIsValidButUserIsBlocked() throws {

        // Arrange.
        let user = try User.create(on: SharedApplication.application(),
                            userName: "timothygreen",
                            email: "timothygreen@testemail.com",
                            name: "Timothy Green")
        let loginRequestDto = LoginRequestDto(userNameOrEmail: "timothygreen", password: "p@ssword")
        let accessTokenDto = try SharedApplication.application()
            .getResponse(to: "/account/login", method: .POST, data: loginRequestDto, decodeTo: AccessTokenDto.self)

        user.isBlocked = true
        try user.update(on: SharedApplication.application())
        let refreshTokenDto = RefreshTokenDto(refreshToken: accessTokenDto.refreshToken)

        // Act.
        let response = try SharedApplication.application()
            .sendRequest(to: "/account/refresh", method: .POST, body: refreshTokenDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (403).")
    }

    static let allTests = [
        ("testNewTokensShouldBeReturnedWhenOldRefreshTokenIsValid", testNewTokensShouldBeReturnedWhenOldRefreshTokenIsValid),
        ("testNewTokensShouldNotBeReturnedWhenOldRefreshTokenIsNotValid", testNewTokensShouldNotBeReturnedWhenOldRefreshTokenIsNotValid),
        ("testNewTokensShouldNotBeReturnedWhenOldRefreshTokenIsValidButUserIsBlocked", testNewTokensShouldNotBeReturnedWhenOldRefreshTokenIsValidButUserIsBlocked)
    ]
}
