@testable import App
import XCTest
import Vapor
import XCTest
import FluentPostgreSQL

final class UserRolesConnectActionTests: XCTestCase {

    func testUserShouldBeConnectedToRoleForSuperUser() throws {
    }

    func testUserShouldNotBeConnectedToRoleIfUserIsNotSuperUser() throws {
    }

    func testCorrectStatsCodeShouldBeReturnedIfUserNotExists() throws {
    }

    func testCorrectStatusCodeShouldBeReturnedIfRoleNotExists() throws {
    }

    static let allTests = [
        ("testUserShouldBeConnectedToRoleForSuperUser", testUserShouldBeConnectedToRoleForSuperUser),
        ("testUserShouldNotBeConnectedToRoleIfUserIsNotSuperUser", testUserShouldNotBeConnectedToRoleIfUserIsNotSuperUser),
        ("testCorrectStatsCodeShouldBeReturnedIfUserNotExists", testCorrectStatsCodeShouldBeReturnedIfUserNotExists),
        ("testCorrectStatusCodeShouldBeReturnedIfRoleNotExists", testCorrectStatusCodeShouldBeReturnedIfRoleNotExists)
    ]
}
