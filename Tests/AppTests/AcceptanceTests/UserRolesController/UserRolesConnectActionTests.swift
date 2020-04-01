@testable import App
import XCTest
import Vapor
import XCTest

/*
final class UserRolesConnectActionTests: XCTestCase {

    func testUserShouldBeConnectedToRoleForSuperUser() throws {

        // Arrange.
        let user = try User.create(on: SharedApplication.application(),
                                   userName: "nickford",
                                   email: "nickford@testemail.com",
                                   name: "Nick Ford")
        try user.attach(roleName: "Administrator", on: SharedApplication.application())
        let role = try Role.create(on: SharedApplication.application(), name: "Consultant", code: "consultant", description: "Consultant")
        let userRoleDto = UserRoleDto(userId: user.id!, roleId: role.id!)

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "nickford", password: "p@ssword"),
            to: "/user-roles/connect",
            method: .POST,
            body: userRoleDto
        )

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.ok, "Response http status code should be ok (200).")
        let roles = try user.getRoles(on: SharedApplication.application())
        XCTAssert(roles.contains { $0.id == role.id! }, "Role should be attached to the user")
    }

    func testNothingShouldHappendWhenUserTriesToConnectAlreadyConnectedRole() throws {

        // Arrange.
        let user = try User.create(on: SharedApplication.application(),
                                   userName: "alanford",
                                   email: "alanford@testemail.com",
                                   name: "Alan Ford")
        let role = try Role.create(on: SharedApplication.application(), name: "Policeman", code: "policeman", description: "Policeman")
        try user.attach(roleName: "Administrator", on: SharedApplication.application())
        try user.attach(roleName: "Policeman", on: SharedApplication.application())
        let userRoleDto = UserRoleDto(userId: user.id!, roleId: role.id!)

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "alanford", password: "p@ssword"),
            to: "/user-roles/connect",
            method: .POST,
            body: userRoleDto
        )

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.ok, "Response http status code should be ok (200).")
        let roles = try user.getRoles(on: SharedApplication.application())
        XCTAssert(roles.contains { $0.id == role.id! }, "Role should be attached to the user")
    }

    func testUserShouldNotBeConnectedToRoleIfUserIsNotSuperUser() throws {

        // Arrange.
        let user = try User.create(on: SharedApplication.application(),
                                   userName: "wandaford",
                                   email: "wandaford@testemail.com",
                                   name: "Wanda Ford")
        let role = try Role.create(on: SharedApplication.application(), name: "Senior consultant", code: "senior-consultant", description: "Senior consultant")
        let userRoleDto = UserRoleDto(userId: user.id!, roleId: role.id!)

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "wandaford", password: "p@ssword"),
            to: "/user-roles/connect",
            method: .POST,
            body: userRoleDto
        )

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.forbidden, "Response http status code should be forbidden (403).")
    }

    func testCorrectStatsCodeShouldBeReturnedIfUserNotExists() throws {

        // Arrange.
        let user = try User.create(on: SharedApplication.application(),
                                   userName: "henryford",
                                   email: "henryford@testemail.com",
                                   name: "Henry Ford")
        try user.attach(roleName: "Administrator", on: SharedApplication.application())
        let role = try Role.create(on: SharedApplication.application(), name: "Junior consultant", code: "junior-consultant", description: "Junior consultant")
        let userRoleDto = UserRoleDto(userId: UUID(), roleId: role.id!)

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "henryford", password: "p@ssword"),
            to: "/user-roles/connect",
            method: .POST,
            body: userRoleDto
        )

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.notFound, "Response http status code should be not found (404).")
    }

    func testCorrectStatusCodeShouldBeReturnedIfRoleNotExists() throws {

        // Arrange.
        let user = try User.create(on: SharedApplication.application(),
                                   userName: "erikford",
                                   email: "erikford@testemail.com",
                                   name: "Erik Ford")
        try user.attach(roleName: "Administrator", on: SharedApplication.application())
        let userRoleDto = UserRoleDto(userId: user.id!, roleId: UUID())

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "erikford", password: "p@ssword"),
            to: "/user-roles/connect",
            method: .POST,
            body: userRoleDto
        )

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.notFound, "Response http status code should be not found (404).")
    }

    static let allTests = [
        ("testUserShouldBeConnectedToRoleForSuperUser", testUserShouldBeConnectedToRoleForSuperUser),
        ("testUserShouldNotBeConnectedToRoleIfUserIsNotSuperUser", testUserShouldNotBeConnectedToRoleIfUserIsNotSuperUser),
        ("testCorrectStatsCodeShouldBeReturnedIfUserNotExists", testCorrectStatsCodeShouldBeReturnedIfUserNotExists),
        ("testCorrectStatusCodeShouldBeReturnedIfRoleNotExists", testCorrectStatusCodeShouldBeReturnedIfRoleNotExists)
    ]
}
*/
