@testable import App
import XCTest
import Vapor
import JWT
import Crypto
import XCTest
import FluentPostgreSQL

final class RegisterActionTests: XCTestCase {

    func testUserAccountShouldBeCreatedForValidUserData() throws {

        // Arrange.
        let registerUserDto = RegisterUserDto(userName: "annasmith",
                                              email: "annasmith@testemail.com",
                                              password: "p@ssword",
                                              name: "Anna Smith",
                                              securityToken: "123")

        // Act.
        let createdUserDto = try SharedApplication.application()
            .getResponse(to: "/register", method: .POST, data: registerUserDto, decodeTo: UserDto.self)

        // Assert.
        XCTAssert(createdUserDto.id != nil, "User wasn't created.")
    }

    func testStatusCodeShouldBeReturnedAfterCreatingNewUser() throws {

        // Arrange.
        let registerUserDto = RegisterUserDto(userName: "martinsmith",
                                              email: "martinsmith@testemail.com",
                                              password: "p@ssword",
                                              name: "Martin Smith",
                                              securityToken: "123")

        // Act.
        let response = try SharedApplication.application().sendRequest(to: "/register", method: .POST, body: registerUserDto)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.created, "Response http status code should be created (201).")
    }

    func testHeaderLocationShouldBeReturnedAfterCreatingNewUser() throws {

        // Arrange.
        let registerUserDto = RegisterUserDto(userName: "victoriasmith",
                                              email: "victoriasmith@testemail.com",
                                              password: "p@ssword",
                                              name: "Victoria Smith",
                                              securityToken: "123")

        // Act.
        let response = try SharedApplication.application().sendRequest(to: "/register", method: .POST, body: registerUserDto)

        // Assert.
        let location = response.http.headers[.location][0]
        let user = try response.content.decode(UserDto.self).wait()
        XCTAssertEqual(location, "/users/\(user.id?.uuidString ?? "")", "Location header should contains created user id.")
    }

    func testCorrectUserDataShouldBeReturnedAfterCreatingNewUser() throws {

        // Arrange.
        let registerUserDto = RegisterUserDto(userName: "dansmith",
                                              email: "dansmith@testemail.com",
                                              password: "p@ssword",
                                              name: "Dan Smith",
                                              bio: "User biography",
                                              location: "London",
                                              website: "http://dansmith.com/",
                                              birthDate: Date(),
                                              securityToken: "123")

        // Act.
        let createdUserDto = try SharedApplication.application().getResponse(to: "/register", method: .POST, data: registerUserDto, decodeTo: UserDto.self)

        // Assert.
        XCTAssertEqual(createdUserDto.userName, "dansmith", "User name is not correcrt.")
        XCTAssertEqual(createdUserDto.email, "dansmith@testemail.com", "Email is not correct.")
        XCTAssertEqual(createdUserDto.name, "Dan Smith", "Name is not correct.")
        XCTAssertEqual(createdUserDto.bio, "User biography", "User biography is not correct")
        XCTAssertEqual(createdUserDto.location, "London", "Location is not correct")
        XCTAssertEqual(createdUserDto.website, "http://dansmith.com/", "Website is not correct")
        XCTAssertEqual(createdUserDto.birthDate?.description, registerUserDto.birthDate?.description, "Birth date is not correct")
        XCTAssertEqual(createdUserDto.gravatarHash, "5a00c583025fbdb133a446223f627a12", "Gravatar is not correct")
    }

    func testNewUserShouldBeAssignedToDefaultRoles() throws {

        // Arrange.
        let registerUserDto = RegisterUserDto(userName: "briansmith",
                                              email: "briansmith@testemail.com",
                                              password: "p@ssword",
                                              name: "Brian Smith",
                                              securityToken: "123")

        // Act.
        _ = try SharedApplication.application().getResponse(to: "/register", method: .POST, data: registerUserDto, decodeTo: UserDto.self)

        // Assert.
        let user = try User.get(on: SharedApplication.application(), userName: "briansmith")
        let roles = try user.getRoles(on: SharedApplication.application())
        XCTAssertEqual(roles[0].code, "member", "Default user roles should be added to user")
    }

    func testUserShouldNotBeCreatedIfUserWithTheSameEmailExists() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "jurgensmith",
                            email: "jurgensmith@testemail.com",
                            name: "Jurgen Smith")

        let registerUserDto = RegisterUserDto(userName: "notexists",
                                              email: "jurgensmith@testemail.com",
                                              password: "p@ssword",
                                              name: "Jurgen Smith",
                                              securityToken: "123")

        // Act.
        let errorResponse = try SharedApplication.application().getErrorResponse(
            to: "/register",
            method: .POST,
            data: registerUserDto
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (400).")
        XCTAssertEqual(errorResponse.error.code, "emailIsAlreadyConnected", "Error code should be equal 'emailIsAlreadyConnected'.")
    }

    func testUserShouldNotBeCreatedIfUserWithTheSameUserNameExists() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "samanthasmith",
                            email: "samanthasmith@testemail.com",
                            name: "Samantha Smith")

        let registerUserDto = RegisterUserDto(userName: "samanthasmith",
                                              email: "samanthasmith-notexists@testemail.com",
                                              password: "p@ssword",
                                              name: "Samantha Smith",
                                              securityToken: "123")

        // Act.
        let errorResponse = try SharedApplication.application().getErrorResponse(
            to: "/register",
            method: .POST,
            data: registerUserDto
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (400).")
        XCTAssertEqual(errorResponse.error.code, "userNameIsAlreadyTaken", "Error code should be equal 'userNameIsAlreadyTaken'.")
    }

    func testUserShouldNotBeCreatedIfUserNameWasNotSpecified() throws {

        // Arrange.
        let registerUserDto = RegisterUserDto(userName: "",
                                              email: "gregsmith@testemail.com",
                                              password: "p@ssword",
                                              name: "Greg Smith",
                                              securityToken: "123")

        // Act.
        let errorResponse = try SharedApplication.application().getErrorResponse(
            to: "/register",
            method: .POST,
            data: registerUserDto
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (400).")
        XCTAssertEqual(errorResponse.error.code, "validationError", "Error code should be equal 'userAccountIsBlocked'.")
        XCTAssertEqual(errorResponse.error.reason, "'userName' is less than required minimum of 1 character", "Error reason should be correct.")
    }

    func testUserShouldNotBeCreatedIfUserNameWasTooLong() throws {
    
        // Arrange.
        let registerUserDto = RegisterUserDto(userName: "123456789012345678901234567890123456789012345678901",
                                              email: "gregsmith@testemail.com",
                                              password: "p@ssword",
                                              name: "Greg Smith",
                                              securityToken: "123")

        // Act.
        let errorResponse = try SharedApplication.application().getErrorResponse(
            to: "/register",
            method: .POST,
            data: registerUserDto
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (400).")
        XCTAssertEqual(errorResponse.error.code, "validationError", "Error code should be equal 'userAccountIsBlocked'.")
        XCTAssertEqual(errorResponse.error.reason, "'userName' is greater than required maximum of 50 characters", "Error reason should be correct.")
    }

    func testUserShouldNotBeCreatedIfEmailWasNotSpecified() throws {

        // Arrange.
        let registerUserDto = RegisterUserDto(userName: "gregsmith",
                                              email: "",
                                              password: "p@ssword",
                                              name: "Greg Smith",
                                              securityToken: "123")

        // Act.
        let errorResponse = try SharedApplication.application().getErrorResponse(
            to: "/register",
            method: .POST,
            data: registerUserDto
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (400).")
        XCTAssertEqual(errorResponse.error.code, "validationError", "Error code should be equal 'userAccountIsBlocked'.")
        XCTAssertEqual(errorResponse.error.reason, "'email' is not a valid email address", "Error reason should be correct.")
    }

    func testUserShouldNotBeCreatedIfEmailHasWrongFormat() throws {

        // Arrange.
        let registerUserDto = RegisterUserDto(userName: "gregsmith",
                                              email: "gregsmithtestemail.com",
                                              password: "p@ssword",
                                              name: "Greg Smith",
                                              securityToken: "123")

        // Act.
        let errorResponse = try SharedApplication.application().getErrorResponse(
            to: "/register",
            method: .POST,
            data: registerUserDto
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (400).")
        XCTAssertEqual(errorResponse.error.code, "validationError", "Error code should be equal 'userAccountIsBlocked'.")
        XCTAssertEqual(errorResponse.error.reason, "'email' is not a valid email address", "Error reason should be correct.")
    }

    func testUserShouldNotBeCreatedIfPasswordWasNotSpecified() throws {

        // Arrange.
        let registerUserDto = RegisterUserDto(userName: "gregsmith",
                                              email: "gregsmith@testemail.com",
                                              password: "",
                                              name: "Greg Smith",
                                              securityToken: "123")

        // Act.
        let errorResponse = try SharedApplication.application().getErrorResponse(
            to: "/register",
            method: .POST,
            data: registerUserDto
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (400).")
        XCTAssertEqual(errorResponse.error.code, "validationError", "Error code should be equal 'userAccountIsBlocked'.")
        XCTAssertEqual(errorResponse.error.reason, "'password' is less than required minimum of 8 characters and 'password' is not a valid password", "Error reason should be correct.")
    }

    func testUserShouldNotBeCreatedIfPasswordIsTooShort() throws {

        // Arrange.
        let registerUserDto = RegisterUserDto(userName: "gregsmith",
                                              email: "gregsmith@testemail.com",
                                              password: "1234567",
                                              name: "Greg Smith",
                                              securityToken: "123")

        // Act.
        let errorResponse = try SharedApplication.application().getErrorResponse(
            to: "/register",
            method: .POST,
            data: registerUserDto
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (400).")
        XCTAssertEqual(errorResponse.error.code, "validationError", "Error code should be equal 'userAccountIsBlocked'.")
        XCTAssertEqual(errorResponse.error.reason, "'password' is less than required minimum of 8 characters and 'password' is not a valid password", "Error reason should be correct.")
    }

    func testUserShouldNotBeCreatedIfPasswordIsTooLong() throws {

        // Arrange.
        let registerUserDto = RegisterUserDto(userName: "gregsmith",
                                              email: "gregsmith@testemail.com",
                                              password: "123456789012345678901234567890123",
                                              name: "Greg Smith",
                                              securityToken: "123")

        // Act.
        let errorResponse = try SharedApplication.application().getErrorResponse(
            to: "/register",
            method: .POST,
            data: registerUserDto
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (400).")
        XCTAssertEqual(errorResponse.error.code, "validationError", "Error code should be equal 'userAccountIsBlocked'.")
        XCTAssertEqual(errorResponse.error.reason, "'password' is greater than required maximum of 32 characters and 'password' is not a valid password", "Error reason should be correct.")
    }

    func testUserShouldNotBeCreatedIfNameIsTooLong() throws {

        // Arrange.
        let registerUserDto = RegisterUserDto(userName: "gregsmith",
                                              email: "gregsmith@testemail.com",
                                              password: "p@ssword",
                                              name: "123456789012345678901234567890123456789012345678901",
                                              securityToken: "123")

        // Act.
        let errorResponse = try SharedApplication.application().getErrorResponse(
            to: "/register",
            method: .POST,
            data: registerUserDto
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (400).")
        XCTAssertEqual(errorResponse.error.code, "validationError", "Error code should be equal 'userAccountIsBlocked'.")
        XCTAssertEqual(errorResponse.error.reason, "'name' is greater than required maximum of 50 characters and 'name' is not nil", "Error reason should be correct.")
    }

    func testUserShouldNotBeCreatedIfLocationIsTooLong() throws {

        // Arrange.
        let registerUserDto = RegisterUserDto(userName: "gregsmith",
                                              email: "gregsmith@testemail.com",
                                              password: "p@ssword",
                                              name: "Greg Smith",
                                              location: "123456789012345678901234567890123456789012345678901",
                                              securityToken: "123")

        // Act.
        let errorResponse = try SharedApplication.application().getErrorResponse(
            to: "/register",
            method: .POST,
            data: registerUserDto
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (400).")
        XCTAssertEqual(errorResponse.error.code, "validationError", "Error code should be equal 'userAccountIsBlocked'.")
        XCTAssertEqual(errorResponse.error.reason, "'location' is greater than required maximum of 50 characters and 'location' is not nil", "Error reason should be correct.")
    }

    func testUserShouldNotBeCreatedIfWebsiteIsTooLong() throws {

        // Arrange.
        let registerUserDto = RegisterUserDto(userName: "gregsmith",
                                              email: "gregsmith@testemail.com",
                                              password: "p@ssword",
                                              name: "Greg Smith",
                                              website: "123456789012345678901234567890123456789012345678901",
                                              securityToken: "123")

        // Act.
        let errorResponse = try SharedApplication.application().getErrorResponse(
            to: "/register",
            method: .POST,
            data: registerUserDto
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (400).")
        XCTAssertEqual(errorResponse.error.code, "validationError", "Error code should be equal 'userAccountIsBlocked'.")
        XCTAssertEqual(errorResponse.error.reason, "'website' is greater than required maximum of 50 characters and 'website' is not nil", "Error reason should be correct.")
    }

    func testUserShouldNotBeCreatedIfBioIsTooLong() throws {

        // Arrange.
        let registerUserDto = RegisterUserDto(userName: "gregsmith",
                                              email: "gregsmith@testemail.com",
                                              password: "p@ssword",
                                              name: "Greg Smith",
                                              bio: "12345678901234567890123456789012345678901234567890" +
                                                   "12345678901234567890123456789012345678901234567890" +
                                                   "12345678901234567890123456789012345678901234567890" +
                                                   "123456789012345678901234567890123456789012345678901",
                                              securityToken: "123")

        // Act.
        let errorResponse = try SharedApplication.application().getErrorResponse(
            to: "/register",
            method: .POST,
            data: registerUserDto
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (400).")
        XCTAssertEqual(errorResponse.error.code, "validationError", "Error code should be equal 'userAccountIsBlocked'.")
        XCTAssertEqual(errorResponse.error.reason, "'bio' is greater than required maximum of 200 characters and 'bio' is not nil", "Error reason should be correct.")
    }

    func testUserShouldNotBeCreatedIfSecurityTokenWasNotSpecified() throws {

        // Arrange.
        let registerUserDto = RegisterUserDto(userName: "gregsmith",
                                              email: "gregsmith@testemail.com",
                                              password: "p@ssword",
                                              name: "Greg Smith",
                                              securityToken: nil)

        // Act.
        let errorResponse = try SharedApplication.application().getErrorResponse(
            to: "/register",
            method: .POST,
            data: registerUserDto
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (400).")
        XCTAssertEqual(errorResponse.error.code, "validationError", "Error code should be equal 'userAccountIsBlocked'.")
        XCTAssertEqual(errorResponse.error.reason, "'securityToken' is nil", "Error reason should be correct.")
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
