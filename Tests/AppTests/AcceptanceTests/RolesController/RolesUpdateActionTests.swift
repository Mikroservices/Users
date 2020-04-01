@testable import App
import XCTest
import Vapor
import XCTest

/*
final class RolesUpdateActionTests: XCTestCase {

    func testCorrectRoleShouldBeUpdatedBySuperUser() throws {

        // Arrange.
        let user = try User.create(on: SharedApplication.application(),
                                   userName: "brucelee",
                                   email: "brucelee@testemail.com",
                                   name: "Bruce Lee")
        try user.attach(roleName: "Administrator", on: SharedApplication.application())
        let role = try Role.create(on: SharedApplication.application(), name: "Seller", code: "seller", description: "Seller")
        let roleToUpdate = RoleDto(id: role.id, name: "Junior serller", code: "junior-seller", description: "Junior seller")

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "brucelee", password: "p@ssword"),
            to: "/roles/\(role.id?.uuidString ?? "")",
            method: .PUT,
            body: roleToUpdate
        )

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.ok, "Response http status code should be ok (200).")
        guard let updatedRole = try? Role.get(on: SharedApplication.application(), name: "Junior serller") else {
            XCTAssert(true, "Role was not found")
            return
        }

        XCTAssertEqual(updatedRole.id, roleToUpdate.id, "Role id should be correct.")
        XCTAssertEqual(updatedRole.name, roleToUpdate.name, "Role name should be correct.")
        XCTAssertEqual(updatedRole.code, roleToUpdate.code, "Role code should be correct.")
        XCTAssertEqual(updatedRole.description, roleToUpdate.description, "Role description should be correct.")
        XCTAssertEqual(updatedRole.hasSuperPrivileges, roleToUpdate.hasSuperPrivileges, "Role super privileges should be correct.")
        XCTAssertEqual(updatedRole.isDefault, roleToUpdate.isDefault, "Role default should be correct.")
    }

    func testRoleShouldNotBeUpdatedIfUserIsNotSuperUser() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "georgelee",
                            email: "georgelee@testemail.com",
                            name: "Geaorge Lee")
        let role = try Role.create(on: SharedApplication.application(), name: "Senior seller", code: "senior-seller", description: "Senior seller")
        let roleToUpdate = RoleDto(id: role.id, name: "Junior serller", code: "junior-seller", description: "Junior seller")

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "georgelee", password: "p@ssword"),
            to: "/roles/\(role.id?.uuidString ?? "")",
            method: .PUT,
            body: roleToUpdate
        )

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.forbidden, "Response http status code should be forbidden (403).")
    }

    func testRoleShouldNotBeUpdatedIfRoleWithSameCodeExists() throws {

        // Arrange.
        let user = try User.create(on: SharedApplication.application(),
                                   userName: "samlee",
                                   email: "samlee@testemail.com",
                                   name: "Sam Lee")
        try user.attach(roleName: "Administrator", on: SharedApplication.application())
        let role = try Role.create(on: SharedApplication.application(), name: "Marketer", code: "marketer", description: "marketer")
        let roleToUpdate = RoleDto(id: role.id, name: "Administrator", code: "administrator", description: "Administrator")

        // Act.
        let errorResponse = try SharedApplication.application().getErrorResponse(
            as: .user(userName: "samlee", password: "p@ssword"),
            to: "/roles/\(role.id?.uuidString ?? "")",
            method: .PUT,
            data: roleToUpdate
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (400).")
        XCTAssertEqual(errorResponse.error.code, "roleWithCodeExists", "Error code should be equal 'roleWithCodeExists'.")
    }

    func testRoleShouldNotBeUpdatedIfCodeIsTooLong() throws {

        // Arrange.
        let user = try User.create(on: SharedApplication.application(),
                                   userName: "wandalee",
                                   email: "wandalee@testemail.com",
                                   name: "Wanda Lee")
        try user.attach(roleName: "Administrator", on: SharedApplication.application())
        let role = try Role.create(on: SharedApplication.application(), name: "Manager1", code: "manager1", description: "Manager")
        let roleToUpdate = RoleDto(id: role.id, name: "Senior manager", code: "123456789012345678901", description: "Senior manager")

        // Act.
        let errorResponse = try SharedApplication.application().getErrorResponse(
            as: .user(userName: "wandalee", password: "p@ssword"),
            to: "/roles/\(role.id?.uuidString ?? "")",
            method: .PUT,
            data: roleToUpdate
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (400).")
        XCTAssertEqual(errorResponse.error.code, "validationError", "Error code should be equal 'validationError'.")
        XCTAssertEqual(errorResponse.error.reason, "'code' is greater than required maximum of 20 characters", "Error reason should be correct.")
    }

    func testRoleShouldNotBeUpdatedIfNameIsTooLong() throws {

        // Arrange.
        let user = try User.create(on: SharedApplication.application(),
                                   userName: "monikalee",
                                   email: "monikalee@testemail.com",
                                   name: "Monika Lee")
        try user.attach(roleName: "Administrator", on: SharedApplication.application())
        let role = try Role.create(on: SharedApplication.application(), name: "Manager2", code: "manager2", description: "Manager")
        let roleToUpdate = RoleDto(id: role.id,
                                   name: "123456789012345678901234567890123456789012345678901",
                                   code: "senior-manager",
                                   description: "Senior manager"
        )

        // Act.
        let errorResponse = try SharedApplication.application().getErrorResponse(
            as: .user(userName: "monikalee", password: "p@ssword"),
            to: "/roles/\(role.id?.uuidString ?? "")",
            method: .PUT,
            data: roleToUpdate
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (400).")
        XCTAssertEqual(errorResponse.error.code, "validationError", "Error code should be equal 'validationError'.")
        XCTAssertEqual(errorResponse.error.reason, "'name' is greater than required maximum of 50 characters", "Error reason should be correct.")
    }

    func testRoleShouldNotBeUpdatedIfDescriptionIsTooLong() throws {

        // Arrange.
        let user = try User.create(on: SharedApplication.application(),
                                   userName: "annalee",
                                   email: "annalee@testemail.com",
                                   name: "Anna Lee")
        try user.attach(roleName: "Administrator", on: SharedApplication.application())
        let role = try Role.create(on: SharedApplication.application(), name: "Manager3", code: "manager3", description: "Manager")
        let roleToUpdate = RoleDto(id: role.id,
                                   name: "Senior manager",
                                   code: "senior-manager",
                                   description: "12345678901234567890123456789012345678901234567890" +
                                                "12345678901234567890123456789012345678901234567890" +
                                                "12345678901234567890123456789012345678901234567890" +
                                                "123456789012345678901234567890123456789012345678901"
        )

        // Act.
        let errorResponse = try SharedApplication.application().getErrorResponse(
            as: .user(userName: "annalee", password: "p@ssword"),
            to: "/roles/\(role.id?.uuidString ?? "")",
            method: .PUT,
            data: roleToUpdate
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.badRequest, "Response http status code should be bad request (400).")
        XCTAssertEqual(errorResponse.error.code, "validationError", "Error code should be equal 'validationError'.")
        XCTAssertEqual(errorResponse.error.reason, "'description' is greater than required maximum of 200 characters and 'description' is not nil", "Error reason should be correct.")
    }

    static let allTests = [
        ("testCorrectRoleShouldBeUpdatedBySuperUser", testCorrectRoleShouldBeUpdatedBySuperUser),
        ("testRoleShouldNotBeUpdatedIfUserIsNotSuperUser", testRoleShouldNotBeUpdatedIfUserIsNotSuperUser),
        ("testRoleShouldNotBeUpdatedIfRoleWithSameCodeExists", testRoleShouldNotBeUpdatedIfRoleWithSameCodeExists),
        ("testRoleShouldNotBeUpdatedIfCodeIsTooLong", testRoleShouldNotBeUpdatedIfCodeIsTooLong),
        ("testRoleShouldNotBeUpdatedIfNameIsTooLong", testRoleShouldNotBeUpdatedIfNameIsTooLong),
        ("testRoleShouldNotBeUpdatedIfDescriptionIsTooLong", testRoleShouldNotBeUpdatedIfDescriptionIsTooLong)
    ]
}
*/
