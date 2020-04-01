@testable import App
import XCTest
import Vapor
import XCTest

/*
final class RolesReadActionTests: XCTestCase {

    func testRoleShouldBeReturnedForSuperUser() throws {

        // Arrange.
        let user = try User.create(on: SharedApplication.application(),
                                   userName: "robinyellow",
                                   email: "robinyellow@testemail.com",
                                   name: "Robin Yellow")
        try user.attach(roleName: "Administrator", on: SharedApplication.application())
        let role = try Role.create(on: SharedApplication.application(),
                                   name: "Senior architect",
                                   code: "senior-architect",
                                   description: "Senior architect")

        // Act.
        let roleDto = try SharedApplication.application().getResponse(
            as: .user(userName: "robinyellow", password: "p@ssword"),
            to: "/roles/\(role.id?.uuidString ?? "")",
            method: .GET,
            decodeTo: RoleDto.self
        )

        // Assert.
        XCTAssertEqual(roleDto.id, role.id, "Role id should be correct.")
        XCTAssertEqual(roleDto.name, role.name, "Role name should be correct.")
        XCTAssertEqual(roleDto.code, role.code, "Role code should be correct.")
        XCTAssertEqual(roleDto.description, role.description, "Role description should be correct.")
        XCTAssertEqual(roleDto.hasSuperPrivileges, role.hasSuperPrivileges, "Role super privileges should be correct.")
        XCTAssertEqual(roleDto.isDefault, role.isDefault, "Role default should be correct.")
    }

    func testRoleShouldNotBeReturnedIfUserIsNotSuperUser() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "hulkyellow",
                            email: "hulkyellow@testemail.com",
                            name: "Hulk Yellow")
        let role = try Role.create(on: SharedApplication.application(),
                                   name: "Senior developer",
                                   code: "senior-developer",
                                   description: "Senior developer")

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "hulkyellow", password: "p@ssword"),
            to: "/roles/\(role.id?.uuidString ?? "")",
            method: .GET
        )

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.forbidden, "Response http status code should be bad request (400).")
    }

    func testCorrectStatusCodeShouldBeReturnedIdRoleNotExists() throws {

        // Arrange.
        let user = try User.create(on: SharedApplication.application(),
                                   userName: "tedyellow",
                                   email: "tedyellow@testemail.com",
                                   name: "Ted Yellow")
        try user.attach(roleName: "Administrator", on: SharedApplication.application())

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "tedyellow", password: "p@ssword"),
            to: "/roles/\(UUID().uuidString)",
            method: .GET
        )

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.notFound, "Response http status code should be not found (404).")
    }

    static let allTests = [
        ("testRoleShouldBeReturnedForSuperUser", testRoleShouldBeReturnedForSuperUser),
        ("testRoleShouldNotBeReturnedIfUserIsNotSuperUser", testRoleShouldNotBeReturnedIfUserIsNotSuperUser),
        ("testCorrectStatusCodeShouldBeReturnedIdRoleNotExists", testCorrectStatusCodeShouldBeReturnedIdRoleNotExists)
    ]
}
*/
