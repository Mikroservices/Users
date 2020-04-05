@testable import App
import XCTest
import XCTVapor

final class RolesDeleteActionTests: XCTestCase {

    func testRoleShouldBeDeletedIfRoleExistsAndUserIsSuperUser() throws {

        // Arrange.
        let user = try User.create(userName: "alinahood",
                                   email: "alinahood@testemail.com",
                                   name: "Alina Hood")
        
        try user.attach(role: "Administrator")
        let roleToDelete = try Role.create(name: "Tester analyst", code: "tester-analyst", description: "Tester analyst")

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "alinahood", password: "p@ssword"),
            to: "/roles/\(roleToDelete.id?.uuidString ?? "")",
            method: .DELETE
        )

        // Assert.
        XCTAssertEqual(response.status, HTTPResponseStatus.ok, "Response http status code should be ok (200).")
        let role = try? Role.get(role: "Tester analyst")
        XCTAssert(role == nil, "Role should be deleted.")
    }

    func testRoleShouldNotBeDeletedIfRoleExistsButUserIsNotSuperUser() throws {

        // Arrange.
        _ = try User.create(userName: "robinhood",
                            email: "robinhood@testemail.com",
                            name: "Robin Hood")
        let roleToDelete = try Role.create(name: "Technican", code: "technican", description: "Technican")

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
        let user = try User.create(userName: "wikihood",
                                   email: "wikihood@testemail.com",
                                   name: "Wiki Hood")
        try user.attach(role: "Administrator")

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
