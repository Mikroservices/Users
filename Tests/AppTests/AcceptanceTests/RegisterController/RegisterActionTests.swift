//
//  RegisterActionTests.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 24/03/2019.
//

@testable import App
import XCTest
import Vapor
import XCTest
import FluentPostgreSQL

final class RegisterActionTests: XCTestCase {

    func testUserAccountShouldBeCreatedForValidUserData() throws {

        // Arrange.
        let userDto = UserDto(userName: "annasmith",
                              email: "annasmith@testemail.com",
                              name: "Anna Smith",
                              password: "p@ssword",
                              securityToken: "123")

        // Act.
        let createdUserDto = try SharedApplication.application().getResponse(to: "/register", method: .POST, data: userDto, decodeTo: UserDto.self)

        // Assert.
        XCTAssert(createdUserDto.id != nil, "User wasn't created.")
    }

    func testStatusCodeShouldBeReturnedAfterCreatingNewUser() throws {

        // Arrange.
        let userDto = UserDto(userName: "martinsmith",
                              email: "martinsmith@testemail.com",
                              name: "Martin Smith",
                              password: "p@ssword",
                              securityToken: "123")

        // Act.
        let response = try SharedApplication.application().sendRequest(to: "/register", method: .POST, body: userDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.created, "Response http status code should be created (201).")
    }

    func testHeaderLocationShouldBeReturnedAfterCreatingNewUser() throws {

        // Arrange.
        let userDto = UserDto(userName: "victoriasmith",
                              email: "victoriasmith@testemail.com",
                              name: "Victoria Smith",
                              password: "p@ssword",
                              securityToken: "123")

        // Act.
        let response = try SharedApplication.application().sendRequest(to: "/register", method: .POST, body: userDto)

        // Assert.
        let location = response.http.headers[.location][0]
        let user = try response.content.decode(UserDto.self).wait()
        XCTAssertEqual(location, "/users/\(user.id?.uuidString ?? "")", "Location header should contains created user id.")
    }

    func testCorrectUserDataShouldBeReturnedAfterCreatingNewUser() throws {

        // Arrange.
        let userDto = UserDto(userName: "dansmith",
                              email: "dansmith@testemail.com",
                              name: "Dan Smith",
                              password: "p@ssword",
                              bio: "User biography",
                              location: "London",
                              website: "http://dansmith.com/",
                              birthDate: Date(),
                              securityToken: "123")

        // Act.
        let createdUserDto = try SharedApplication.application().getResponse(to: "/register", method: .POST, data: userDto, decodeTo: UserDto.self)

        // Assert.
        XCTAssertEqual(createdUserDto.userName, "dansmith", "User name is not correcrt.")
        XCTAssertEqual(createdUserDto.email, "dansmith@testemail.com", "Email is not correct.")
        XCTAssertEqual(createdUserDto.name, "Dan Smith", "Name is not correct.")
        XCTAssertEqual(createdUserDto.password, nil, "Password is not nil.")
        XCTAssertEqual(createdUserDto.bio, "User biography", "User biography is not correct")
        XCTAssertEqual(createdUserDto.location, "London", "Location is not correct")
        XCTAssertEqual(createdUserDto.website, "http://dansmith.com/", "Website is not correct")
        XCTAssertEqual(createdUserDto.birthDate?.description, userDto.birthDate?.description, "Birth date is not correct")
        XCTAssertEqual(createdUserDto.securityToken, nil, "Security token is not nil")
        XCTAssertEqual(createdUserDto.gravatarHash, "5a00c583025fbdb133a446223f627a12", "Gravatar is not correct")
    }

    func testUserShouldNotBeCreatedIfUserWithTheSameEmailExists() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "jurgensmith",
                            email: "jurgensmith@testemail.com",
                            name: "Jurgen Smith")

        let userDto = UserDto(userName: "jurgensmith-notexists",
                              email: "jurgensmith@testemail.com",
                              name: "Jurgen Smith",
                              password: "p@ssword",
                              securityToken: "123")

        // Act.
        let response = try SharedApplication.application().sendRequest(to: "/register", method: .POST, body: userDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.badRequest, "Response http status code should be created (201).")
    }

    func testUserShouldNotBeCreatedIfUserWithTheSameUserNameExists() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "samanthasmith",
                            email: "samanthasmith@testemail.com",
                            name: "Samantha Smith")

        let userDto = UserDto(userName: "samanthasmith",
                              email: "samanthasmith-notexists@testemail.com",
                              name: "Samantha Smith",
                              password: "p@ssword",
                              securityToken: "123")

        // Act.
        let response = try SharedApplication.application().sendRequest(to: "/register", method: .POST, body: userDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.badRequest, "Response http status code should be created (201).")
    }

    static let allTests = [
        ("testUserAccountShouldBeCreatedForValidUserData", testUserAccountShouldBeCreatedForValidUserData),
        ("testStatusCodeShouldBeReturnedAfterCreatingNewUser", testStatusCodeShouldBeReturnedAfterCreatingNewUser),
        ("testHeaderLocationShouldBeReturnedAfterCreatingNewUser", testHeaderLocationShouldBeReturnedAfterCreatingNewUser),
        ("testCorrectUserDataShouldBeReturnedAfterCreatingNewUser", testCorrectUserDataShouldBeReturnedAfterCreatingNewUser),
        ("testUserShouldNotBeCreatedIfUserWithTheSameEmailExists", testUserShouldNotBeCreatedIfUserWithTheSameEmailExists),
        ("testUserShouldNotBeCreatedIfUserWithTheSameUserNameExists", testUserShouldNotBeCreatedIfUserWithTheSameUserNameExists)
    ]
}
