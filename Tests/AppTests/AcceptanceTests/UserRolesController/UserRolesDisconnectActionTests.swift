@testable import App
import XCTest
import Vapor
import XCTest
import FluentPostgreSQL

final class UserRolesDisconnectActionTests: XCTestCase {

    func testUserShouldBeDisconnectedWithRoleForSuperUser() throws {
    }

    func testUserShouldNotBeDisconnectedWithRoleIfUserIsNotSuperUser() throws {
    }

    func testCorrectStatsCodeShouldBeReturnedIfUserNotExists() throws {
    }

    func testCorrectStatusCodeShouldBeReturnedIfRoleNotExists() throws {
    }

    static let allTests = [
        ("testUserShouldBeDisconnectedWithRoleForSuperUser", testUserShouldBeDisconnectedWithRoleForSuperUser),
        ("testUserShouldNotBeDisconnectedWithRoleIfUserIsNotSuperUser", testUserShouldNotBeDisconnectedWithRoleIfUserIsNotSuperUser),
        ("testCorrectStatsCodeShouldBeReturnedIfUserNotExists", testCorrectStatsCodeShouldBeReturnedIfUserNotExists),
        ("testCorrectStatusCodeShouldBeReturnedIfRoleNotExists", testCorrectStatusCodeShouldBeReturnedIfRoleNotExists)
    ]
}
