//
//  DeleteActionTests.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 26/03/2019.
//

@testable import App
import XCTest
import Vapor
import XCTest
import FluentPostgreSQL

final class DeleteActionTests: XCTestCase {
    
    func testUserShouldBeDeletedForAuthorizedUser() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "zibibonjek",
                            email: "zibibonjek@testemail.com",
                            name: "Zibi Bonjek",
                            password: "83427d87b9492b7e048a975025190efa55edb9948ae7ced5c6ccf1a553ce0e2b",
                            salt: "TNhZYL4F66KY7fUuqS/Juw==")
        let loginRequestDto = LoginRequestDto(userNameOrEmail: "zibibonjek", password: "p@ssword")
        let accessTokenDto = try SharedApplication.application()
            .getResponse(to: "/account/login", method: .POST, data: loginRequestDto, decodeTo: AccessTokenDto.self)
        let headers: HTTPHeaders = [ HTTPHeaderName.authorization.description: "Bearer \(accessTokenDto.accessToken)" ]

        // Act.
        let response = try SharedApplication.application()
            .sendRequest(to: "/users/@zibibonjek", method: .DELETE, headers: headers)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.ok, "Response http status code should be ok (200).")
        let user = try? User.get(on: SharedApplication.application(), userName: "zibibonjek")
        XCTAssert(user == nil, "User should be deleted.")
    }

    func testUnauthorizedStatusCodeShouldBeReturnedForUnauthorizedUser() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "victoriabonjek",
                            email: "victoriabonjek@testemail.com",
                            name: "Victoria Bonjek",
                            password: "83427d87b9492b7e048a975025190efa55edb9948ae7ced5c6ccf1a553ce0e2b",
                            salt: "TNhZYL4F66KY7fUuqS/Juw==")

        // Act.
        let response = try SharedApplication.application()
            .sendRequest(to: "/users/@victoriabonjek", method: .DELETE)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.unauthorized, "Response http status code should be unauthorized (401).")
    }

    func testForbiddenStatusCodeShouldBeReturnedForOtherUserData() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "martabonjek",
                            email: "martabonjek@testemail.com",
                            name: "Marta Bonjek",
                            password: "83427d87b9492b7e048a975025190efa55edb9948ae7ced5c6ccf1a553ce0e2b",
                            salt: "TNhZYL4F66KY7fUuqS/Juw==")

        _ = try User.create(on: SharedApplication.application(),
                            userName: "kingabonjek",
                            email: "kingabonjek@testemail.com",
                            name: "Kinga Bonjek",
                            password: "83427d87b9492b7e048a975025190efa55edb9948ae7ced5c6ccf1a553ce0e2b",
                            salt: "TNhZYL4F66KY7fUuqS/Juw==")


        let loginRequestDto = LoginRequestDto(userNameOrEmail: "martabonjek", password: "p@ssword")
        let accessTokenDto = try SharedApplication.application()
            .getResponse(to: "/account/login", method: .POST, data: loginRequestDto, decodeTo: AccessTokenDto.self)
        let headers: HTTPHeaders = [ HTTPHeaderName.authorization.description: "Bearer \(accessTokenDto.accessToken)" ]

        // Act.
        let response = try SharedApplication.application()
            .sendRequest(to: "/users/@kingabonjek", method: .DELETE, headers: headers)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.forbidden, "Response http status code should be forbidden (403).")
    }

    func testNotFoundStatusCodeShouldBeReturnedIfUserNotExists() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "henrybonjek",
                            email: "henrybonjek@testemail.com",
                            name: "Henry Bonjek",
                            password: "83427d87b9492b7e048a975025190efa55edb9948ae7ced5c6ccf1a553ce0e2b",
                            salt: "TNhZYL4F66KY7fUuqS/Juw==")
        let loginRequestDto = LoginRequestDto(userNameOrEmail: "henrybonjek", password: "p@ssword")
        let accessTokenDto = try SharedApplication.application()
            .getResponse(to: "/account/login", method: .POST, data: loginRequestDto, decodeTo: AccessTokenDto.self)
        let headers: HTTPHeaders = [ HTTPHeaderName.authorization.description: "Bearer \(accessTokenDto.accessToken)" ]

        // Act.
        let response = try SharedApplication.application()
            .sendRequest(to: "/users/@notexists", method: .DELETE, headers: headers)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.notFound, "Response http status code should be not found (404).")
    }

    static let allTests = [
        ("testUserShouldBeDeletedForAuthorizedUser", testUserShouldBeDeletedForAuthorizedUser),
        ("testUnauthorizedStatusCodeShouldBeReturnedForUnauthorizedUser", testUnauthorizedStatusCodeShouldBeReturnedForUnauthorizedUser),
        ("testForbiddenStatusCodeShouldBeReturnedForOtherUserData", testForbiddenStatusCodeShouldBeReturnedForOtherUserData),
        ("testNotFoundStatusCodeShouldBeReturnedIfUserNotExists", testNotFoundStatusCodeShouldBeReturnedIfUserNotExists)
    ]
}