@testable import App
import XCTest
import Vapor
import XCTest
import FluentPostgreSQL

final class RolesReadActionTests: XCTestCase {

    func testRoleShouldBeReturnedForSuperUser() throws {
    }

    func testRoleShouldNotBeReturnedIfUserIsNotSuperUser() throws {
    }

    func testCorrectStatusCodeShouldBeReturnedIdRoleNotExists() throws {
    }

    static let allTests = [
        ("testRoleShouldBeReturnedForSuperUser", testRoleShouldBeReturnedForSuperUser),
        ("testRoleShouldNotBeReturnedIfUserIsNotSuperUser", testRoleShouldNotBeReturnedIfUserIsNotSuperUser),
        ("testCorrectStatusCodeShouldBeReturnedIdRoleNotExists", testCorrectStatusCodeShouldBeReturnedIdRoleNotExists)
    ]
}
