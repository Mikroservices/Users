//
//  ProfileActionTests.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 25/03/2019.
//

@testable import App
import XCTest
import Vapor
import XCTest
import FluentPostgreSQL

final class ProfileActionTests: XCTestCase {

    func testUserProfileShouldBeReturnedForExistingUser() throws {

        // Arrange.
        let user = try User.create(on: SharedApplication.application(),
                                   userName: "johnbush",
                                   email: "johnbush@testemail.com",
                                   name: "John Bush",
                                   password: "83427d87b9492b7e048a975025190efa55edb9948ae7ced5c6ccf1a553ce0e2b",
                                   salt: "TNhZYL4F66KY7fUuqS/Juw==",
                                   emailWasConfirmed: true,
                                   isBlocked: false,
                                   emailConfirmationGuid: "",
                                   gravatarHash: "048a975025190efa55edb9948ae7ced5",
                                   forgotPasswordGuid: "1234567890",
                                   forgotPasswordDate: Date(),
                                   bio: "Developer in most innovative company.",
                                   location: "Cupertino",
                                   website: "http://johnbush.com",
                                   birthDate: Date())
        let loginRequestDto = LoginRequestDto(userNameOrEmail: "johnbush", password: "p@ssword")
        let accessTokenDto = try SharedApplication.application()
            .getResponse(to: "/account/login", method: .POST, data: loginRequestDto, decodeTo: AccessTokenDto.self)
        let headers: HTTPHeaders = [ HTTPHeaderName.authorization.description: "Bearer \(accessTokenDto.accessToken)" ]

        // Act.
        let userDto = try SharedApplication.application()
            .getResponse(to: "/users/@johnbush", headers: headers, decodeTo: UserDto.self)

        // Assert.
        XCTAssertEqual(userDto.id, user.id, "Property 'id' should be equal.")
        XCTAssertEqual(userDto.userName, user.userName, "Property 'userName' should be equal.")
        XCTAssertEqual(userDto.email, user.email, "Property 'email' should be equal.")
        XCTAssertEqual(userDto.name, user.name, "Property 'name' should be equal.")
        XCTAssertEqual(userDto.gravatarHash, user.gravatarHash, "Property 'gravatarHash' should be equal.")
        XCTAssertEqual(userDto.bio, user.bio, "Property 'bio' should be equal.")
        XCTAssertEqual(userDto.location, user.location, "Property 'location' should be equal.")
        XCTAssertEqual(userDto.website, user.website, "Property 'website' should be equal.")
        XCTAssertEqual(userDto.birthDate, user.birthDate, "Property 'birthDate' should be equal.")
    }

    func testUserProfileShouldNotBeReturnedForNotExistingUser() throws {

        // Arrange.

        // Act.
        let response = try SharedApplication.application().sendRequest(to: "/users/@not-exists", method: .GET)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.unauthorized, "Response http status code should be unauthorized (404).")
    }

    func testPublicProfileShouldNotContainsSensitiveInformation() throws {

        // Arrange.
        let user = try User.create(on: SharedApplication.application(),
                                   userName: "elizabush",
                                   email: "elizabush@testemail.com",
                                   name: "Eliza Bush",
                                   password: "83427d87b9492b7e048a975025190efa55edb9948ae7ced5c6ccf1a553ce0e2b",
                                   salt: "TNhZYL4F66KY7fUuqS/Juw==",
                                   emailWasConfirmed: true,
                                   isBlocked: false,
                                   emailConfirmationGuid: "",
                                   gravatarHash: "75025190efa55edb9948ae7ced5c6ccf1a553c",
                                   forgotPasswordGuid: "1234567890",
                                   forgotPasswordDate: Date(),
                                   bio: "Tester in most innovative company.",
                                   location: "Cupertino",
                                   website: "http://elizabush.com",
                                   birthDate: Date())

        // Act.
        let userDto = try SharedApplication.application()
            .getResponse(to: "/users/@elizabush", decodeTo: UserDto.self)

        // Assert.
        XCTAssertEqual(userDto.id, user.id, "Property 'id' should be equal.")
        XCTAssertEqual(userDto.userName, user.userName, "Property 'userName' should be equal.")
        XCTAssertEqual(userDto.email, user.email, "Property 'email' should be equal.")
        XCTAssertEqual(userDto.name, user.name, "Property 'name' should be equal.")
        XCTAssertEqual(userDto.gravatarHash, user.gravatarHash, "Property 'gravatarHash' should be equal.")
        XCTAssertEqual(userDto.bio, user.bio, "Property 'bio' should be equal.")
        XCTAssertEqual(userDto.location, user.location, "Property 'location' should be equal.")
        XCTAssertEqual(userDto.website, user.website, "Property 'website' should be equal.")
        XCTAssert(userDto.birthDate == nil, "Property 'birthDate' must not be returned.")
    }

    static let allTests = [
        ("testUserProfileShouldBeReturnedForExistingUser", testUserProfileShouldBeReturnedForExistingUser),
        ("testUserProfileShouldNotBeReturnedForNotExistingUser", testUserProfileShouldNotBeReturnedForNotExistingUser),
        ("testPublicProfileShouldNotContainsSensitiveInformation", testPublicProfileShouldNotContainsSensitiveInformation)
    ]
}
