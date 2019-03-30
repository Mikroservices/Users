@testable import App
import XCTest
import Vapor
import XCTest
import FluentPostgreSQL

final class RolesDeleteActionTests: XCTestCase {

    func testRoleShouldBeDeletedIfRoleExistsAndUserIsSuperUser() throws {

        // Arrange.
        let user = try User.create(on: SharedApplication.application(),
                                   userName: "alinahood",
                                   email: "alinahood@testemail.com",
                                   name: "Alina Hood")
        try user.attach(roleName: "Administrator", on: SharedApplication.application())
        let roleToDelete = try Role.create(on: SharedApplication.application(), name: "Tester analyst", code: "tester-analyst", description: "Tester analyst")

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "alinahood", password: "p@ssword"),
            to: "/roles/\(roleToDelete.id?.uuidString ?? "")",
            method: .DELETE
        )

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.ok, "Response http status code should be ok (200).")
        let role = try? Role.get(on: SharedApplication.application(), name: "Tester analyst")
        XCTAssert(role == nil, "Role should be deleted.")
    }

    func testRoleShouldNotBeDeletedIfRoleExistsButUserIsNotSuperUser() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "robinhood",
                            email: "robinhood@testemail.com",
                            name: "Robin Hood")
        let roleToDelete = try Role.create(on: SharedApplication.application(), name: "Technican", code: "technican", description: "Technican")

        // Act.
        let errorResponse = try SharedApplication.application().getErrorResponse(
            as: .user(userName: "robinhood", password: "p@ssword"),
            to: "/roles/\(roleToDelete.id?.uuidString ?? "")",
            method: .DELETE
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.forbidden, "Response http status code should be bad request (400).")
    }

    func testCorrectStatusCodeShouldBeReturnedIfRoleNotExists() throws {

        // Arrange.
        let user = try User.create(on: SharedApplication.application(),
                                   userName: "wikihood",
                                   email: "wikihood@testemail.com",
                                   name: "Wiki Hood")
        try user.attach(roleName: "Administrator", on: SharedApplication.application())

        // Act.
        let errorResponse = try SharedApplication.application().getErrorResponse(
            as: .user(userName: "wikihood", password: "p@ssword"),
            to: "/roles/\(UUID().uuidString)",
            method: .DELETE
        )

        // Assert.
        XCTAssertEqual(errorResponse.status, HTTPResponseStatus.notFound, "Response http status code should be not found (404).")
    }

    static let allTests = [
        ("testRoleShouldBeDeletedIfRoleExistsAndUserIsSuperUser", testRoleShouldBeDeletedIfRoleExistsAndUserIsSuperUser),
        ("testRoleShouldNotBeDeletedIfRoleExistsButUserIsNotSuperUser", testRoleShouldNotBeDeletedIfRoleExistsButUserIsNotSuperUser),
        ("testCorrectStatusCodeShouldBeReturnedIfRoleNotExists", testCorrectStatusCodeShouldBeReturnedIfRoleNotExists)
    ]
}
