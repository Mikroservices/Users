@testable import App
import XCTest
import Vapor
import XCTest
import FluentPostgreSQL

final class RolesCreateActionTests: XCTestCase {

    func testRoleShouldBeCreatedBySuperUser() throws {

        // Arrange.
        let user = try User.create(on: SharedApplication.application(),
                                   userName: "laracroft",
                                   email: "laracroft@testemail.com",
                                   name: "Lara Croft")
        try user.attach(roleName: "Administrator", on: SharedApplication.application())
        let roleDto = RoleDto(name: "Reviewer", code: "reviewer", description: "Code reviewers")

        // Act.
        let createdRoleDto = try SharedApplication.application().getResponse(
            as: .user(userName: "laracroft", password: "p@ssword"),
            to: "/roles",
            method: .POST,
            data: roleDto,
            decodeTo: RoleDto.self
        )

        // Assert.
        XCTAssert(createdRoleDto.id != nil, "Role wasn't created.")
    }

    func testCreatedStatusCodeShouldBeReturnedAfterCreatingNewRole() throws {

        // Arrange.
        let user = try User.create(on: SharedApplication.application(),
                                   userName: "martincroft",
                                   email: "martincroft@testemail.com",
                                   name: "Martin Croft")
        try user.attach(roleName: "Administrator", on: SharedApplication.application())
        let roleDto = RoleDto(name: "Technical writer", code: "tech-writer", description: "Technical writer")

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "martincroft", password: "p@ssword"),
            to: "/roles",
            method: .POST,
            body: roleDto
        )

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.created, "Response http status code should be created (201).")
    }

    func testHeaderLocationShouldBeReturnedAfterCreatingNewRole() throws {

        // Arrange.
        let user = try User.create(on: SharedApplication.application(),
                                   userName: "victorcroft",
                                   email: "victorcroft@testemail.com",
                                   name: "Victor Croft")
        try user.attach(roleName: "Administrator", on: SharedApplication.application())
        let roleDto = RoleDto(name: "Business analyst", code: "business-analyst", description: "Business analyst")

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "victorcroft", password: "p@ssword"),
            to: "/roles",
            method: .POST,
            body: roleDto
        )

        // Assert.
        let location = response.http.headers[.location][0]
        let role = try response.content.decode(RoleDto.self).wait()
        XCTAssertEqual(location, "/roles/\(role.id?.uuidString ?? "")", "Location header should contains created role id.")
    }

    func testRoleShouldNotBeCreatedIfUserIsNotSuperUser() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "robincroft",
                            email: "robincroft@testemail.com",
                            name: "Robin Croft")
        let roleDto = RoleDto(name: "Developer", code: "developer", description: "Developer")

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "robincroft", password: "p@ssword"),
            to: "/roles",
            method: .POST,
            body: roleDto
        )

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.forbidden, "Response http status code should be forbidden (403).")
    }

    func testRoleShouldNotBeCreatedIfRoleWithSameCodeExists() throws {

        // Arrange.
        let user = try User.create(on: SharedApplication.application(),
                                   userName: "erikcroft",
                                   email: "erikcroft@testemail.com",
                                   name: "Erik Croft")
        try user.attach(roleName: "Administrator", on: SharedApplication.application())
        let roleDto = RoleDto(name: "Administrator", code: "administrator", description: "Administrator")

        // Act.
        let errorResponse = try SharedApplication.application().getErrorResponse(
            as: .user(userName: "erikcroft", password: "p@ssword"),
            to: "/roles",
            method: .POST,
            data: roleDto
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (400).")
        XCTAssertEqual(errorResponse.error.code, "roleWithCodeExists", "Error code should be equal 'roleWithCodeExists'.")
    }

    func testRoleShouldNotBeCreatedIfCodeIsTooLong() throws {

        // Arrange.
        let user = try User.create(on: SharedApplication.application(),
                                   userName: "tedcroft",
                                   email: "tedcroft@testemail.com",
                                   name: "Ted Croft")
        try user.attach(roleName: "Administrator", on: SharedApplication.application())
        let roleDto = RoleDto(name: "name", code: "123456789012345678901", description: "description")

        // Act.
        let errorResponse = try SharedApplication.application().getErrorResponse(
            as: .user(userName: "tedcroft", password: "p@ssword"),
            to: "/roles",
            method: .POST,
            data: roleDto
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (400).")
        XCTAssertEqual(errorResponse.error.code, "validationError", "Error code should be equal 'validationError'.")
        XCTAssertEqual(errorResponse.error.reason, "'code' is greater than required maximum of 20 characters", "Error reason should be correct.")
    }

    func testRoleShouldNotBeCreatedIfNameIsTooLong() throws {

        // Arrange.
        let user = try User.create(on: SharedApplication.application(),
                                   userName: "romancroft",
                                   email: "romancroft@testemail.com",
                                   name: "Roman Croft")
        try user.attach(roleName: "Administrator", on: SharedApplication.application())
        let roleDto = RoleDto(name: "123456789012345678901234567890123456789012345678901", code: "code", description: "description")

        // Act.
        let errorResponse = try SharedApplication.application().getErrorResponse(
            as: .user(userName: "romancroft", password: "p@ssword"),
            to: "/roles",
            method: .POST,
            data: roleDto
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (400).")
        XCTAssertEqual(errorResponse.error.code, "validationError", "Error code should be equal 'validationError'.")
        XCTAssertEqual(errorResponse.error.reason, "'name' is greater than required maximum of 50 characters", "Error reason should be correct.")
    }

    func testRoleShouldNotBeCreatedIfDescriptionIsTooLong() throws {

        // Arrange.
        let user = try User.create(on: SharedApplication.application(),
                                   userName: "samcroft",
                                   email: "samcroft@testemail.com",
                                   name: "Sam Croft")
        try user.attach(roleName: "Administrator", on: SharedApplication.application())
        let roleDto = RoleDto(name: "name",
                              code: "code",
                              description: "12345678901234567890123456789012345678901234567890" +
                                           "12345678901234567890123456789012345678901234567890" +
                                           "12345678901234567890123456789012345678901234567890" +
                                           "123456789012345678901234567890123456789012345678901"
        )

        // Act.
        let errorResponse = try SharedApplication.application().getErrorResponse(
            as: .user(userName: "samcroft", password: "p@ssword"),
            to: "/roles",
            method: .POST,
            data: roleDto
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (400).")
        XCTAssertEqual(errorResponse.error.code, "validationError", "Error code should be equal 'validationError'.")
        XCTAssertEqual(errorResponse.error.reason, "'description' is greater than required maximum of 200 characters and 'description' is not nil", "Error reason should be correct.")
    }

    static let allTests = [
        ("testRoleShouldBeCreatedBySuperUser", testRoleShouldBeCreatedBySuperUser),
        ("testRoleShouldNotBeCreatedIfUserIsNotSuperUser", testRoleShouldNotBeCreatedIfUserIsNotSuperUser),
        ("testRoleShouldNotBeCreatedIfRoleWithSameCodeExists", testRoleShouldNotBeCreatedIfRoleWithSameCodeExists),
        ("testRoleShouldNotBeCreatedIfCodeIsTooLong", testRoleShouldNotBeCreatedIfCodeIsTooLong),
        ("testRoleShouldNotBeCreatedIfNameIsTooLong", testRoleShouldNotBeCreatedIfNameIsTooLong),
        ("testRoleShouldNotBeCreatedIfDescriptionIsTooLong", testRoleShouldNotBeCreatedIfDescriptionIsTooLong)
    ]
}
