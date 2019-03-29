@testable import App
import XCTest
import Vapor
import XCTest
import FluentPostgreSQL

final class RolesUpdateActionTests: XCTestCase {

    func testCorrectRoleShouldBeUpdatedBySuperUser() throws {
    }

    func testRoleShouldNotBeUpdatedIfUserIsNotSuperUser() throws {
    }

    func testRoleShouldNotBeUpdatedIfRoleWithSameCodeExists() throws {
    }

    func testRoleShouldNotBeUpdatedIfCodeIsTooLong() throws {
    }

    func testRoleShouldNotBeUpdatedIfNameIsTooLong() throws {
    }

    func testRoleShouldNotBeUpdatedIfDescriptionIsTooLong() throws {
    }

    static let allTests = [
        ("testCorrectRoleShouldBeUpdatedBySuperUser", testCorrectRoleShouldBeUpdatedBySuperUser),
        ("testRoleShouldNotBeUpdatedIfUserIsNotSuperUser", testRoleShouldNotBeUpdatedIfUserIsNotSuperUser),
        ("testRoleShouldNotBeUpdatedIfRoleWithSameCodeExists", testRoleShouldNotBeUpdatedIfRoleWithSameCodeExists),
        ("testRoleShouldNotBeUpdatedIfCodeIsTooLong", testRoleShouldNotBeUpdatedIfCodeIsTooLong),
        ("testRoleShouldNotBeUpdatedIfNameIsTooLong", testRoleShouldNotBeUpdatedIfNameIsTooLong),
        ("testRoleShouldNotBeUpdatedIfDescriptionIsTooLong", testRoleShouldNotBeUpdatedIfDescriptionIsTooLong)
    ]
}
