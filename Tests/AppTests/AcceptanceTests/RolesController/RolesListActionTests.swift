@testable import App
import XCTest
import Vapor
import XCTest
import FluentPostgreSQL

final class RolesListActionTests: XCTestCase {

    func testListOfRolesShouldBeReturnedForSuperUser() throws {
    }

    func testListOfRolesShouldNotBeReturnedForNotSuperUser() throws {
    }

    static let allTests = [
        ("testListOfRolesShouldBeReturnedForSuperUser", testListOfRolesShouldBeReturnedForSuperUser),
        ("testListOfRolesShouldNotBeReturnedForNotSuperUser", testListOfRolesShouldNotBeReturnedForNotSuperUser)
    ]
}
