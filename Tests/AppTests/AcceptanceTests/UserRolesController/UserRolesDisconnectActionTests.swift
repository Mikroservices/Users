@testable import App
import XCTest
import XCTVapor
import Fluent

final class UserRolesDisconnectActionTests: XCTestCase {

    func testUserShouldBeDisconnectedWithRoleForSuperUser() throws {

        // Arrange.
        let user = try User.create(userName: "nickviolet",
                                   email: "nickviolet@testemail.com",
                                   name: "Nick Violet")
        
        let administrator = try Role.get(role: "Administrator")
        try user.$roles.attach(administrator, on: SharedApplication.application().db).wait()
        
        let role = try Role.create(name: "Accountant", code: "accountant", description: "Accountant")
        try user.$roles.attach(role, on: SharedApplication.application().db).wait()
        
        let userRoleDto = UserRoleDto(userId: user.id!, roleId: role.id!)

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "nickviolet", password: "p@ssword"),
            to: "/user-roles/disconnect",
            method: .POST,
            body: userRoleDto
        )

        // Assert.
        XCTAssertEqual(response.status, HTTPResponseStatus.ok, "Response http status code should be ok (200).")
        let userFromDb = try User.query(on: SharedApplication.application().db).filter(\.$userName == "nickviolet").with(\.$roles).first().wait()
        XCTAssert(!userFromDb!.roles.contains { $0.id == role.id! }, "Role should not be attached to the user")
    }

    func testNothingShouldHappanedWhenUserTriesDisconnectNotConnectedRole() throws {

        // Arrange.
        let user = try User.create(userName: "alanviolet",
                                   email: "alanviolet@testemail.com",
                                   name: "Alan Violet")
        
        let administrator = try Role.get(role: "Administrator")
        try user.$roles.attach(administrator, on: SharedApplication.application().db).wait()
        
        let role = try Role.create(name: "Teacher", code: "teacher", description: "Teacher")
        let userRoleDto = UserRoleDto(userId: user.id!, roleId: role.id!)

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "alanviolet", password: "p@ssword"),
            to: "/user-roles/disconnect",
            method: .POST,
            body: userRoleDto
        )

        // Assert.
        XCTAssertEqual(response.status, HTTPResponseStatus.ok, "Response http status code should be ok (200).")
        let userFromDb = try User.query(on: SharedApplication.application().db).filter(\.$userName == "alanviolet").with(\.$roles).first().wait()
        XCTAssert(!userFromDb!.roles.contains { $0.id == role.id! }, "Role should not be attached to the user")
    }

    func testUserShouldNotBeDisconnectedWithRoleIfUserIsNotSuperUser() throws {

        // Arrange.
        let user = try User.create(userName: "ronaldviolet",
                                   email: "ronaldviolet@testemail.com",
                                   name: "Ronald Violet")
        let role = try Role.create(name: "Junior accountant", code: "junior-consultant", description: "Junior accountant")
        try user.$roles.attach(role, on: SharedApplication.application().db).wait()
        let userRoleDto = UserRoleDto(userId: user.id!, roleId: role.id!)

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "ronaldviolet", password: "p@ssword"),
            to: "/user-roles/disconnect",
            method: .POST,
            body: userRoleDto
        )

        // Assert.
        XCTAssertEqual(response.status, HTTPResponseStatus.forbidden, "Response http status code should be forbidden (403).")
    }

    func testCorrectStatsCodeShouldBeReturnedIfUserNotExists() throws {

        // Arrange.
        let user = try User.create(userName: "wikiviolet",
                                   email: "wikiviolet@testemail.com",
                                   name: "Wiki Violet")
        let role = try Role.create(name: "Senior accountant", code: "senior-consultant", description: "Senior accountant")
        try user.$roles.attach(role, on: SharedApplication.application().db).wait()
        
        let administrator = try Role.get(role: "Administrator")
        try user.$roles.attach(administrator, on: SharedApplication.application().db).wait()
        
        let userRoleDto = UserRoleDto(userId: UUID(), roleId: role.id!)

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "wikiviolet", password: "p@ssword"),
            to: "/user-roles/disconnect",
            method: .POST,
            body: userRoleDto
        )

        // Assert.
        XCTAssertEqual(response.status, HTTPResponseStatus.notFound, "Response http status code should be not found (404).")
    }

    func testCorrectStatusCodeShouldBeReturnedIfRoleNotExists() throws {

        // Arrange.
        let user = try User.create(userName: "danviolet",
                                   email: "danviolet@testemail.com",
                                   name: "Dan Violet")
        let administrator = try Role.get(role: "Administrator")
        try user.$roles.attach(administrator, on: SharedApplication.application().db).wait()
        let userRoleDto = UserRoleDto(userId: UUID(), roleId: UUID())

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "danviolet", password: "p@ssword"),
            to: "/user-roles/disconnect",
            method: .POST,
            body: userRoleDto
        )

        // Assert.
        XCTAssertEqual(response.status, HTTPResponseStatus.notFound, "Response http status code should be not found (404).")
    }

    static let allTests = [
        ("testUserShouldBeDisconnectedWithRoleForSuperUser", testUserShouldBeDisconnectedWithRoleForSuperUser),
        ("testUserShouldNotBeDisconnectedWithRoleIfUserIsNotSuperUser", testUserShouldNotBeDisconnectedWithRoleIfUserIsNotSuperUser),
        ("testCorrectStatsCodeShouldBeReturnedIfUserNotExists", testCorrectStatsCodeShouldBeReturnedIfUserNotExists),
        ("testCorrectStatusCodeShouldBeReturnedIfRoleNotExists", testCorrectStatusCodeShouldBeReturnedIfRoleNotExists)
    ]
}
