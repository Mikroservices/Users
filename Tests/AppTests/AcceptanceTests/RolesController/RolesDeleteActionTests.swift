@testable import App
import XCTest
import Vapor
import XCTest
import FluentPostgreSQL

final class RolesDeleteActionTests: XCTestCase {

    func testRoleShouldBeDeletedIfRoleExistsAndUserIsSuperUser() throws {
    }

    func testRoleShouldNotBeDeletedIfRoleExistsButUserIsNotSuperUser() throws {
    }

    func testCorrectStatusCodeShouldBeReturnedIfRoleNotExists() throws {
    }

    static let allTests = [
        ("testRoleShouldBeDeletedIfRoleExistsAndUserIsSuperUser", testRoleShouldBeDeletedIfRoleExistsAndUserIsSuperUser),
        ("testRoleShouldNotBeDeletedIfRoleExistsButUserIsNotSuperUser", testRoleShouldNotBeDeletedIfRoleExistsButUserIsNotSuperUser),
        ("testCorrectStatusCodeShouldBeReturnedIfRoleNotExists", testCorrectStatusCodeShouldBeReturnedIfRoleNotExists)
    ]
}
