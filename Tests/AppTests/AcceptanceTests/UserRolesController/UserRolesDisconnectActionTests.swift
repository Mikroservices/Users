@testable import App
import XCTest
import Vapor
import XCTest

/*
final class UserRolesDisconnectActionTests: XCTestCase {

    func testUserShouldBeDisconnectedWithRoleForSuperUser() throws {

        // Arrange.
        let user = try User.create(on: SharedApplication.application(),
                                   userName: "nickviolet",
                                   email: "nickviolet@testemail.com",
                                   name: "Nick Violet")
        let role = try Role.create(on: SharedApplication.application(), name: "Accountant", code: "accountant", description: "Accountant")
        try user.attach(roleName: "Administrator", on: SharedApplication.application())
        try user.attach(roleName: "Accountant", on: SharedApplication.application())
        let userRoleDto = UserRoleDto(userId: user.id!, roleId: role.id!)

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "nickviolet", password: "p@ssword"),
            to: "/user-roles/disconnect",
            method: .POST,
            body: userRoleDto
        )

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.ok, "Response http status code should be ok (200).")
        let roles = try user.getRoles(on: SharedApplication.application())
        XCTAssert(!roles.contains { $0.id == role.id! }, "Role should not be attached to the user")
    }

    func testNothingShouldHappanedWhenUserTriesDisconnectNotConnectedRole() throws {

        // Arrange.
        let user = try User.create(on: SharedApplication.application(),
                                   userName: "alanviolet",
                                   email: "alanviolet@testemail.com",
                                   name: "Alan Violet")
        let role = try Role.create(on: SharedApplication.application(), name: "Teacher", code: "teacher", description: "Teacher")
        try user.attach(roleName: "Administrator", on: SharedApplication.application())
        let userRoleDto = UserRoleDto(userId: user.id!, roleId: role.id!)

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "alanviolet", password: "p@ssword"),
            to: "/user-roles/disconnect",
            method: .POST,
            body: userRoleDto
        )

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.ok, "Response http status code should be ok (200).")
        let roles = try user.getRoles(on: SharedApplication.application())
        XCTAssert(!roles.contains { $0.id == role.id! }, "Role should not be attached to the user")
    }

    func testUserShouldNotBeDisconnectedWithRoleIfUserIsNotSuperUser() throws {

        // Arrange.
        let user = try User.create(on: SharedApplication.application(),
                                   userName: "ronaldviolet",
                                   email: "ronaldviolet@testemail.com",
                                   name: "Ronald Violet")
        let role = try Role.create(on: SharedApplication.application(), name: "Junior accountant", code: "junior-consultant", description: "Junior accountant")
        try user.attach(roleName: "Junior accountant", on: SharedApplication.application())
        let userRoleDto = UserRoleDto(userId: user.id!, roleId: role.id!)

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "ronaldviolet", password: "p@ssword"),
            to: "/user-roles/disconnect",
            method: .POST,
            body: userRoleDto
        )

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.forbidden, "Response http status code should be forbidden (403).")
    }

    func testCorrectStatsCodeShouldBeReturnedIfUserNotExists() throws {

        // Arrange.
        let user = try User.create(on: SharedApplication.application(),
                                   userName: "wikiviolet",
                                   email: "wikiviolet@testemail.com",
                                   name: "Wiki Violet")
        let role = try Role.create(on: SharedApplication.application(), name: "Senior accountant", code: "senior-consultant", description: "Senior accountant")
        try user.attach(roleName: "Administrator", on: SharedApplication.application())
        try user.attach(roleName: "Senior accountant", on: SharedApplication.application())
        let userRoleDto = UserRoleDto(userId: UUID(), roleId: role.id!)

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "wikiviolet", password: "p@ssword"),
            to: "/user-roles/disconnect",
            method: .POST,
            body: userRoleDto
        )

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.notFound, "Response http status code should be not found (404).")
    }

    func testCorrectStatusCodeShouldBeReturnedIfRoleNotExists() throws {

        // Arrange.
        let user = try User.create(on: SharedApplication.application(),
                                   userName: "danviolet",
                                   email: "danviolet@testemail.com",
                                   name: "Dan Violet")
        try user.attach(roleName: "Administrator", on: SharedApplication.application())
        let userRoleDto = UserRoleDto(userId: UUID(), roleId: UUID())

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "danviolet", password: "p@ssword"),
            to: "/user-roles/disconnect",
            method: .POST,
            body: userRoleDto
        )

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.notFound, "Response http status code should be not found (404).")
    }

    static let allTests = [
        ("testUserShouldBeDisconnectedWithRoleForSuperUser", testUserShouldBeDisconnectedWithRoleForSuperUser),
        ("testUserShouldNotBeDisconnectedWithRoleIfUserIsNotSuperUser", testUserShouldNotBeDisconnectedWithRoleIfUserIsNotSuperUser),
        ("testCorrectStatsCodeShouldBeReturnedIfUserNotExists", testCorrectStatsCodeShouldBeReturnedIfUserNotExists),
        ("testCorrectStatusCodeShouldBeReturnedIfRoleNotExists", testCorrectStatusCodeShouldBeReturnedIfRoleNotExists)
    ]
}
*/
