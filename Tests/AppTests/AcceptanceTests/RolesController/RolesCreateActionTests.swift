@testable import App
import XCTest
import Vapor
import XCTest
import FluentPostgreSQL

final class RolesCreateActionTests: XCTestCase {

    func testCorrectRoleShouldBeCreatedBySuperUser() throws {
    }

    func testRoleShouldNotBeCreatedIfUserIsNotSuperUser() throws {
    }

    func testRoleShouldNotBeCreatedIfRoleWithSameCodeExists() throws {
    }

    func testRoleShouldNotBeCreatedIfCodeIsTooLong() throws {
    }

    func testRoleShouldNotBeCreatedIfNameIsTooLong() throws {
    }

    func testRoleShouldNotBeCreatedIfDescriptionIsTooLong() throws {
    }

    static let allTests = [
        ("testCorrectRoleShouldBeCreatedBySuperUser", testCorrectRoleShouldBeCreatedBySuperUser),
        ("testRoleShouldNotBeCreatedIfUserIsNotSuperUser", testRoleShouldNotBeCreatedIfUserIsNotSuperUser),
        ("testRoleShouldNotBeCreatedIfRoleWithSameCodeExists", testRoleShouldNotBeCreatedIfRoleWithSameCodeExists),
        ("testRoleShouldNotBeCreatedIfCodeIsTooLong", testRoleShouldNotBeCreatedIfCodeIsTooLong),
        ("testRoleShouldNotBeCreatedIfNameIsTooLong", testRoleShouldNotBeCreatedIfNameIsTooLong),
        ("testRoleShouldNotBeCreatedIfDescriptionIsTooLong", testRoleShouldNotBeCreatedIfDescriptionIsTooLong)
    ]
}
