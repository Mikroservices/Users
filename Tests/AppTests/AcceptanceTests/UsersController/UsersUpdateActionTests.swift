@testable import App
import XCTest
import Vapor
import XCTest

/*
final class UsersUpdateActionTests: XCTestCase {
    
    func testAccountShouldBeUpdatedForAuthorizedUser() throws {

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

        let userDto = UserDto(id: UUID(),
                              userName: "user name should not be changed",
                              email: "email should not be changed",
                              gravatarHash: "gravatarHash should not be changed",
                              name: "Nick Perry-Fear",
                              bio: "Architect in most innovative company.",
                              location: "San Francisco",
                              website: "http://architect.com",
                              birthDate: Date())

        // Act.
        let updatedUserDto = try SharedApplication.application().getResponse(
            as: .user(userName: "nickperry", password: "p@ssword"),
            to: "/users/@nickperry",
            method: .PUT,
            data: userDto,
            decodeTo: UserDto.self
        )

        // Assert.
        XCTAssertEqual(updatedUserDto.id, user.id, "Property 'user' should not be changed.")
        XCTAssertEqual(updatedUserDto.userName, user.userName, "Property 'userName' should not be changed.")
        XCTAssertEqual(updatedUserDto.email, user.email, "Property 'email' should not be changed.")
        XCTAssertEqual(updatedUserDto.gravatarHash, user.gravatarHash, "Property 'gravatarHash' should not be changed.")
        XCTAssertEqual(updatedUserDto.name, userDto.name, "Property 'name' should be changed.")
        XCTAssertEqual(updatedUserDto.bio, userDto.bio, "Property 'bio' should be changed.")
        XCTAssertEqual(updatedUserDto.location, userDto.location, "Property 'location' should be changed.")
        XCTAssertEqual(updatedUserDto.website, userDto.website, "Property 'website' should be changed.")
        XCTAssertEqual(updatedUserDto.birthDate?.description, userDto.birthDate?.description, "Property 'birthDate' should be changed.")
    }

    func testAccountShouldNotBeUpdatedIfUserIsNotAuthorized() throws {

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
                              bio: "Architect in most innovative company.",
                              location: "San Francisco",
                              website: "http://architect.com",
                              birthDate: Date())

        // Act.
        let response = try SharedApplication.application()
            .sendRequest(to: "/users/@josepfperry", method: .PUT, body: userDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.unauthorized, "Response http status code should be unauthorized (401).")
    }

    func testAccountShouldNotUpdatedWhenUserTriesToUpdateNotHisAccount() throws {

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

        let userDto = UserDto(id: UUID(), userName: "chrisperry", email: "chrisperry@testemail.com", name: "Tiger Perry")

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "annaperry", password: "p@ssword"),
            to: "/users/@josepfperry",
            method: .PUT,
            body: userDto
        )

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.forbidden, "Response http status code should be forbidden (403).")
    }

    func testAccountShouldNotBeUpdatedIfNameIsTooLong() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "brianperry",
                            email: "brianperry@testemail.com",
                            name: "Brian Perry")

        let userDto = UserDto(userName: "brianperry",
                              email: "gregsmith@testemail.com",
                              name: "123456789012345678901234567890123456789012345678901")

        // Act.
        let errorResponse = try SharedApplication.application().getErrorResponse(
            as: .user(userName: "brianperry", password: "p@ssword"),
            to: "/users/@brianperry",
            method: .PUT,
            data: userDto
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (400).")
        XCTAssertEqual(errorResponse.error.code, "validationError", "Error code should be equal 'userAccountIsBlocked'.")
        XCTAssertEqual(errorResponse.error.reason, "'name' is greater than required maximum of 50 characters and 'name' is not nil", "Error reason should be correct.")
    }

    func testAccountShouldNotBeUpdatedIfLocationIsTooLong() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "chrisperry",
                            email: "chrisperry@testemail.com",
                            name: "Chris Perry")

        let userDto = UserDto(userName: "chrisperry",
                              email: "gregsmith@testemail.com",
                              name: "Chris Perry",
                              location: "123456789012345678901234567890123456789012345678901")

        // Act.
        let errorResponse = try SharedApplication.application().getErrorResponse(
            as: .user(userName: "chrisperry", password: "p@ssword"),
            to: "/users/@chrisperry",
            method: .PUT,
            data: userDto
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (400).")
        XCTAssertEqual(errorResponse.error.code, "validationError", "Error code should be equal 'userAccountIsBlocked'.")
        XCTAssertEqual(errorResponse.error.reason, "'location' is greater than required maximum of 50 characters and 'location' is not nil", "Error reason should be correct.")
    }

    func testAccountShouldNotBeUpdatedIfWebsiteIsTooLong() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "lukeperry",
                            email: "lukeperry@testemail.com",
                            name: "Luke Perry")

        let userDto = UserDto(userName: "lukeperry",
                              email: "gregsmith@testemail.com",
                              name: "Chris Perry",
                              website: "123456789012345678901234567890123456789012345678901")

        // Act.
        let errorResponse = try SharedApplication.application().getErrorResponse(
            as: .user(userName: "lukeperry", password: "p@ssword"),
            to: "/users/@lukeperry",
            method: .PUT,
            data: userDto
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (400).")
        XCTAssertEqual(errorResponse.error.code, "validationError", "Error code should be equal 'userAccountIsBlocked'.")
        XCTAssertEqual(errorResponse.error.reason, "'website' is greater than required maximum of 50 characters and 'website' is not nil", "Error reason should be correct.")
    }

    func testAccountShouldNotBeUpdatedIfBioIsTooLong() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "francisperry",
                            email: "francisperry@testemail.com",
                            name: "Francis Perry")

        let userDto = UserDto(userName: "francisperry",
                              email: "gregsmith@testemail.com",
                              name: "Chris Perry",
                              bio: "12345678901234567890123456789012345678901234567890" +
                                "12345678901234567890123456789012345678901234567890" +
                                "12345678901234567890123456789012345678901234567890" +
                                "123456789012345678901234567890123456789012345678901")

        // Act.
        let errorResponse = try SharedApplication.application().getErrorResponse(
            as: .user(userName: "francisperry", password: "p@ssword"),
            to: "/users/@francisperry",
            method: .PUT,
            data: userDto
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (400).")
        XCTAssertEqual(errorResponse.error.code, "validationError", "Error code should be equal 'userAccountIsBlocked'.")
        XCTAssertEqual(errorResponse.error.reason, "'bio' is greater than required maximum of 200 characters and 'bio' is not nil", "Error reason should be correct.")
    }

    static let allTests = [
        ("testAccountShouldBeUpdatedForAuthorizedUser", testAccountShouldBeUpdatedForAuthorizedUser),
        ("testAccountShouldNotBeUpdatedIfUserIsNotAuthorized", testAccountShouldNotBeUpdatedIfUserIsNotAuthorized),
        ("testAccountShouldNotUpdatedWhenUserTriesToUpdateNotHisAccount", testAccountShouldNotUpdatedWhenUserTriesToUpdateNotHisAccount),
        ("testAccountShouldNotBeUpdatedIfNameIsTooLong", testAccountShouldNotBeUpdatedIfNameIsTooLong),
        ("testAccountShouldNotBeUpdatedIfLocationIsTooLong", testAccountShouldNotBeUpdatedIfLocationIsTooLong),
        ("testAccountShouldNotBeUpdatedIfWebsiteIsTooLong", testAccountShouldNotBeUpdatedIfWebsiteIsTooLong),
        ("testAccountShouldNotBeUpdatedIfBioIsTooLong", testAccountShouldNotBeUpdatedIfBioIsTooLong)
    ]
}
*/
