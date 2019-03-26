//
//  UpdateActionTests.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 26/03/2019.
//

@testable import App
import XCTest
import Vapor
import XCTest
import FluentPostgreSQL

final class UpdateActionTests: XCTestCase {
    
    func testUserDataShouldBeUpdatedForAuthorizedUser() throws {

        // Arrange.
        let user = try User.create(on: SharedApplication.application(),
                                   userName: "nickperry",
                                   email: "nickperry@testemail.com",
                                   name: "Nick Perry",
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
                                   website: "http://nickperry.com",
                                   birthDate: Date())
        let loginRequestDto = LoginRequestDto(userNameOrEmail: "nickperry", password: "p@ssword")
        let accessTokenDto = try SharedApplication.application()
            .getResponse(to: "/account/login", method: .POST, data: loginRequestDto, decodeTo: AccessTokenDto.self)
        let headers: HTTPHeaders = [ HTTPHeaderName.authorization.description: "Bearer \(accessTokenDto.accessToken)" ]

        let userDto = UserDto(id: UUID(),
                              userName: "user name should not be changed",
                              email: "email should not be changed",
                              gravatarHash: "gravatarHash should not be changed",
                              name: "Nick Perry-Fear",
                              password: "password?",
                              bio: "Architect in most innovative company.",
                              location: "San Francisco",
                              website: "http://architect.com",
                              birthDate: Date(),
                              securityToken: "security")

        // Act.
        let updatedUserDto = try SharedApplication.application()
            .getResponse(to: "/users/@nickperry", method: .PUT, headers: headers, data: userDto, decodeTo: UserDto.self)

        // Assert.
        XCTAssertEqual(updatedUserDto.id, user.id, "Property 'user' should not be changed.")
        XCTAssertEqual(updatedUserDto.userName, user.userName, "Property 'userName' should not be changed.")
        XCTAssertEqual(updatedUserDto.email, user.email, "Property 'email' should not be changed.")
        XCTAssertEqual(updatedUserDto.gravatarHash, user.gravatarHash, "Property 'gravatarHash' should not be changed.")
        XCTAssertEqual(updatedUserDto.name, userDto.name, "Property 'name' should be changed.")
        XCTAssertEqual(updatedUserDto.bio, userDto.bio, "Property 'bio' should be changed.")
        XCTAssertEqual(updatedUserDto.location, userDto.location, "Property 'location' should be changed.")
        XCTAssertEqual(updatedUserDto.website, userDto.website, "Property 'website' should be changed.")
        XCTAssertEqual(updatedUserDto.birthDate, userDto.birthDate, "Property 'birthDate' should be changed.")
    }

    func testUnauthorizedStatusCodeShouldBeReturnedForUnauthorizedUser() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "josepfperry",
                            email: "josepfperry@testemail.com",
                            name: "Joseph Perry",
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
                            website: "http://josepfperry.com",
                            birthDate: Date())

        let userDto = UserDto(id: UUID(),
                              userName: "user name should not be changed",
                              email: "email should not be changed",
                              gravatarHash: "gravatarHash should not be changed",
                              name: "Nick Perry-Fear",
                              password: "password?",
                              bio: "Architect in most innovative company.",
                              location: "San Francisco",
                              website: "http://architect.com",
                              birthDate: Date(),
                              securityToken: "security")

        // Act.
        let response = try SharedApplication.application()
            .sendRequest(to: "/users/@josepfperry", method: .PUT, body: userDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.unauthorized, "Response http status code should be unauthorized (401).")
    }

    func testForbiddenStatusCodeShouldBeReturnedForOtherUserData() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "annaperry",
                            email: "annaperry@testemail.com",
                            name: "Anna Perry",
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
                            website: "http://annaperry.com",
                            birthDate: Date())

        _ = try User.create(on: SharedApplication.application(),
                            userName: "chrisperry",
                            email: "chrisperry@testemail.com",
                            name: "Chris Perry",
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
                            website: "http://chrisperry.com",
                            birthDate: Date())

        let loginRequestDto = LoginRequestDto(userNameOrEmail: "annaperry", password: "p@ssword")
        let accessTokenDto = try SharedApplication.application()
            .getResponse(to: "/account/login", method: .POST, data: loginRequestDto, decodeTo: AccessTokenDto.self)
        let headers: HTTPHeaders = [ HTTPHeaderName.authorization.description: "Bearer \(accessTokenDto.accessToken)" ]

        let userDto = UserDto(id: UUID(), userName: "chrisperry", email: "chrisperry@testemail.com", name: "Tiger Perry")

        // Act.
        let response = try SharedApplication.application()
            .sendRequest(to: "/users/@josepfperry", method: .PUT, headers: headers, body: userDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.forbidden, "Response http status code should be forbidden (403).")
    }

    static let allTests = [
        ("testUserDataShouldBeUpdatedForAuthorizedUser", testUserDataShouldBeUpdatedForAuthorizedUser),
        ("testUnauthorizedStatusCodeShouldBeReturnedForUnauthorizedUser", testUnauthorizedStatusCodeShouldBeReturnedForUnauthorizedUser),
        ("testForbiddenStatusCodeShouldBeReturnedForOtherUserData", testForbiddenStatusCodeShouldBeReturnedForOtherUserData)
    ]
}