@testable import App
import XCTest
import XCTVapor


final class RolesCreateActionTests: XCTestCase {

    func testRoleShouldBeCreatedBySuperUser() throws {

        // Arrange.
        let user = try User.create(userName: "laracroft",
                                   email: "laracroft@testemail.com",
                                   name: "Lara Croft")
        try user.attach(role: "Administrator")
        let roleDto = RoleDto(title: "Reviewer", code: "reviewer", description: "Code reviewers", hasSuperPrivileges: false, isDefault: true)

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
        let user = try User.create(userName: "martincroft",
                                   email: "martincroft@testemail.com",
                                   name: "Martin Croft")
        try user.attach(role: "Administrator")
        let roleDto = RoleDto(title: "Technical writer", code: "tech-writer", description: "Technical writer", hasSuperPrivileges: false, isDefault: true)

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "martincroft", password: "p@ssword"),
            to: "/roles",
            method: .POST,
            body: roleDto
        )

        // Assert.
        XCTAssertEqual(response.status, HTTPResponseStatus.created, "Response http status code should be created (201).")
    }

    func testHeaderLocationShouldBeReturnedAfterCreatingNewRole() throws {

        // Arrange.
        let user = try User.create(userName: "victorcroft",
                                   email: "victorcroft@testemail.com",
                                   name: "Victor Croft")
        try user.attach(role: "Administrator")
        let roleDto = RoleDto(title: "Business analyst", code: "business-analyst", description: "Business analyst", hasSuperPrivileges: false, isDefault: true)

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "victorcroft", password: "p@ssword"),
            to: "/roles",
            method: .POST,
            body: roleDto
        )

        // Assert.
        let location = response.headers.first(name: .location)
        let role = try response.content.decode(RoleDto.self)
        XCTAssertEqual(location, "/roles/\(role.id?.uuidString ?? "")", "Location header should contains created role id.")
    }

    func testRoleShouldNotBeCreatedIfUserIsNotSuperUser() throws {

        // Arrange.
        _ = try User.create(userName: "robincroft",
                            email: "robincroft@testemail.com",
                            name: "Robin Croft")
        let roleDto = RoleDto(title: "Developer", code: "developer", description: "Developer", hasSuperPrivileges: false, isDefault: true)

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "robincroft", password: "p@ssword"),
            to: "/roles",
            method: .POST,
            body: roleDto
        )

        // Assert.
        XCTAssertEqual(response.status, HTTPResponseStatus.forbidden, "Response http status code should be forbidden (403).")
    }

    func testRoleShouldNotBeCreatedIfRoleWithSameCodeExists() throws {

        // Arrange.
        let user = try User.create(userName: "erikcroft",
                                   email: "erikcroft@testemail.com",
                                   name: "Erik Croft")
        try user.attach(role: "Administrator")
        let roleDto = RoleDto(title: "Administrator", code: "administrator", description: "Administrator", hasSuperPrivileges: false, isDefault: true)

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
        let user = try User.create(userName: "tedcroft",
                                   email: "tedcroft@testemail.com",
                                   name: "Ted Croft")
        try user.attach(role: "Administrator")
        let roleDto = RoleDto(title: "name", code: "123456789012345678901", description: "description", hasSuperPrivileges: false, isDefault: true)

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
        XCTAssertEqual(errorResponse.error.reason, "Validation errors occurs.")
        XCTAssertEqual(errorResponse.error.failures?.getFailure("code"), "is greater than maximum of 20 character(s)")
    }

    func testRoleShouldNotBeCreatedIfNameIsTooLong() throws {

        // Arrange.
        let user = try User.create(userName: "romancroft",
                                   email: "romancroft@testemail.com",
                                   name: "Roman Croft")
        try user.attach(role: "Administrator")
        let roleDto = RoleDto(title: "123456789012345678901234567890123456789012345678901", code: "code", description: "description", hasSuperPrivileges: false, isDefault: true)

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
        XCTAssertEqual(errorResponse.error.reason, "Validation errors occurs.")
        XCTAssertEqual(errorResponse.error.failures?.getFailure("title"), "is greater than maximum of 50 character(s)")
    }

    func testRoleShouldNotBeCreatedIfDescriptionIsTooLong() throws {

        // Arrange.
        let user = try User.create(userName: "samcroft",
                                   email: "samcroft@testemail.com",
                                   name: "Sam Croft")
        try user.attach(role: "Administrator")
        let roleDto = RoleDto(title: "name",
                              code: "code",
                              description: "12345678901234567890123456789012345678901234567890" +
                                           "12345678901234567890123456789012345678901234567890" +
                                           "12345678901234567890123456789012345678901234567890" +
                                           "123456789012345678901234567890123456789012345678901",
                              hasSuperPrivileges: false,
                              isDefault: true)

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
        XCTAssertEqual(errorResponse.error.reason, "Validation errors occurs.")
        XCTAssertEqual(errorResponse.error.failures?.getFailure("description"), "is greater than maximum of 200 character(s) and is not null")
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

