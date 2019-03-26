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

    func testUserShouldNotBeCreatedIfUserNameWasNotSpecified() throws {

        // Arrange.
        let userDto = UserDto(userName: "",
                              email: "gregsmith@testemail.com",
                              name: "Greg Smith",
                              password: "p@ssword",
                              securityToken: "123")

        // Act.
        let response = try SharedApplication.application().sendRequest(to: "/register", method: .POST, body: userDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (403).")
    }

    func testUserShouldNotBeCreatedIfUserNameWasTooLong() throws {
    
        // Arrange.
        let userDto = UserDto(userName: "123456789012345678901234567890123456789012345678901",
                              email: "gregsmith@testemail.com",
                              name: "Greg Smith",
                              password: "p@ssword",
                              securityToken: "123")

        // Act.
        let response = try SharedApplication.application().sendRequest(to: "/register", method: .POST, body: userDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (403).")
    }

    func testUserShouldNotBeCreatedIfEmailWasNotSpecified() throws {

        // Arrange.
        let userDto = UserDto(userName: "gregsmith",
                              email: "",
                              name: "Greg Smith",
                              password: "p@ssword",
                              securityToken: "123")

        // Act.
        let response = try SharedApplication.application().sendRequest(to: "/register", method: .POST, body: userDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (403).")
    }

    func testUserShouldNotBeCreatedIfEmailHasWrongFormat() throws {

        // Arrange.
        let userDto = UserDto(userName: "gregsmith",
                              email: "gregsmithtestemail.com",
                              name: "Greg Smith",
                              password: "p@ssword",
                              securityToken: "123")

        // Act.
        let response = try SharedApplication.application().sendRequest(to: "/register", method: .POST, body: userDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (403).")
    }

    func testUserShouldNotBeCreatedIfPasswordWasNotSpecified() throws {

        // Arrange.
        let userDto = UserDto(userName: "gregsmith",
                              email: "gregsmith@testemail.com",
                              name: "Greg Smith",
                              password: "",
                              securityToken: "123")

        // Act.
        let response = try SharedApplication.application().sendRequest(to: "/register", method: .POST, body: userDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (403).")
    }

    func testUserShouldNotBeCreatedIfPasswordIsTooShort() throws {

        // Arrange.
        let userDto = UserDto(userName: "gregsmith",
                              email: "gregsmith@testemail.com",
                              name: "Greg Smith",
                              password: "1234567",
                              securityToken: "123")

        // Act.
        let response = try SharedApplication.application().sendRequest(to: "/register", method: .POST, body: userDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (403).")
    }

    func testUserShouldNotBeCreatedIfPasswordIsTooLong() throws {

        // Arrange.
        let userDto = UserDto(userName: "gregsmith",
                              email: "gregsmith@testemail.com",
                              name: "Greg Smith",
                              password: "123456789012345678901234567890123",
                              securityToken: "123")

        // Act.
        let response = try SharedApplication.application().sendRequest(to: "/register", method: .POST, body: userDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (403).")
    }

    func testUserShouldNotBeCreatedIfNameIsTooLong() throws {

        // Arrange.
        let userDto = UserDto(userName: "gregsmith",
                              email: "gregsmith@testemail.com",
                              name: "123456789012345678901234567890123456789012345678901",
                              password: "p@ssword",
                              securityToken: "123")

        // Act.
        let response = try SharedApplication.application().sendRequest(to: "/register", method: .POST, body: userDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (403).")
    }

    func testUserShouldNotBeCreatedIfLocationIsTooLong() throws {

        // Arrange.
        let userDto = UserDto(userName: "gregsmith",
                              email: "gregsmith@testemail.com",
                              name: "Greg Smith",
                              password: "p@ssword",
                              location: "123456789012345678901234567890123456789012345678901",
                              securityToken: "123")

        // Act.
        let response = try SharedApplication.application().sendRequest(to: "/register", method: .POST, body: userDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (403).")
    }

    func testUserShouldNotBeCreatedIfWebsiteIsTooLong() throws {

        // Arrange.
        let userDto = UserDto(userName: "gregsmith",
                              email: "gregsmith@testemail.com",
                              name: "Greg Smith",
                              password: "p@ssword",
                              website: "123456789012345678901234567890123456789012345678901",
                              securityToken: "123")

        // Act.
        let response = try SharedApplication.application().sendRequest(to: "/register", method: .POST, body: userDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (403).")
    }

    func testUserShouldNotBeCreatedIfBioIsTooLong() throws {

        // Arrange.
        let userDto = UserDto(userName: "gregsmith",
                              email: "gregsmith@testemail.com",
                              name: "Greg Smith",
                              password: "p@ssword",
                              bio: "12345678901234567890123456789012345678901234567890" +
                                "12345678901234567890123456789012345678901234567890" +
                                "12345678901234567890123456789012345678901234567890" +
                                "123456789012345678901234567890123456789012345678901",
                              securityToken: "123")

        // Act.
        let response = try SharedApplication.application().sendRequest(to: "/register", method: .POST, body: userDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (403).")
    }

    func testUserShouldNotBeCreatedIfSecurityTokenWasNotSpecified() throws {

        // Arrange.
        let userDto = UserDto(userName: "gregsmith",
                              email: "gregsmith@testemail.com",
                              name: "Greg Smith",
                              password: "p@ssword",
                              securityToken: "")

        // Act.
        let response = try SharedApplication.application().sendRequest(to: "/register", method: .POST, body: userDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (403).")
    }

    static let allTests = [
        ("testUserAccountShouldBeCreatedForValidUserData", testUserAccountShouldBeCreatedForValidUserData),
        ("testStatusCodeShouldBeReturnedAfterCreatingNewUser", testStatusCodeShouldBeReturnedAfterCreatingNewUser),
        ("testHeaderLocationShouldBeReturnedAfterCreatingNewUser", testHeaderLocationShouldBeReturnedAfterCreatingNewUser),
        ("testCorrectUserDataShouldBeReturnedAfterCreatingNewUser", testCorrectUserDataShouldBeReturnedAfterCreatingNewUser),
        ("testUserShouldNotBeCreatedIfUserWithTheSameEmailExists", testUserShouldNotBeCreatedIfUserWithTheSameEmailExists),
        ("testUserShouldNotBeCreatedIfUserWithTheSameUserNameExists", testUserShouldNotBeCreatedIfUserWithTheSameUserNameExists),
        ("testUserShouldNotBeCreatedIfUserNameWasNotSpecified", testUserShouldNotBeCreatedIfUserNameWasNotSpecified),
        ("testUserShouldNotBeCreatedIfUserNameWasTooLong", testUserShouldNotBeCreatedIfUserNameWasTooLong),
        ("testUserShouldNotBeCreatedIfEmailWasNotSpecified", testUserShouldNotBeCreatedIfEmailWasNotSpecified),
        ("testUserShouldNotBeCreatedIfEmailHasWrongFormat", testUserShouldNotBeCreatedIfEmailHasWrongFormat),
        ("testUserShouldNotBeCreatedIfPasswordWasNotSpecified", testUserShouldNotBeCreatedIfPasswordWasNotSpecified),
        ("testUserShouldNotBeCreatedIfPasswordIsTooShort", testUserShouldNotBeCreatedIfPasswordIsTooShort),
        ("testUserShouldNotBeCreatedIfPasswordIsTooLong", testUserShouldNotBeCreatedIfPasswordIsTooLong),
        ("testUserShouldNotBeCreatedIfNameIsTooLong", testUserShouldNotBeCreatedIfNameIsTooLong),
        ("testUserShouldNotBeCreatedIfLocationIsTooLong", testUserShouldNotBeCreatedIfLocationIsTooLong),
        ("testUserShouldNotBeCreatedIfWebsiteIsTooLong", testUserShouldNotBeCreatedIfWebsiteIsTooLong),
        ("testUserShouldNotBeCreatedIfBioIsTooLong", testUserShouldNotBeCreatedIfBioIsTooLong),
        ("testUserShouldNotBeCreatedIfSecurityTokenWasNotSpecified", testUserShouldNotBeCreatedIfSecurityTokenWasNotSpecified)
    ]
}
