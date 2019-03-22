@testable import App
import XCTest
import Vapor
import XCTest
import FluentPostgreSQL

final class RegisterControllerTests: XCTestCase {

    func testUserNameValidationShouldReturnTrueIfUserNameExists() throws {

        // Arrange.
        let url = "/register/userName/mczachurski"

        // Act.
        let booleanResponseDto = try SharedApplication.application()
            .getResponse(to: url, decodeTo: BooleanResponseDto.self)

        // Assert.
        XCTAssert(booleanResponseDto.result, "Server should return true for username: mczachurski")
    }

    func testUserNameValidationShouldReturnFalseIfUserNameNotExists() throws {

        // Arrange.
        let url = "/register/userName/notexists"

        // Act.
        let booleanResponseDto = try SharedApplication.application()
            .getResponse(to: url, decodeTo: BooleanResponseDto.self)

        // add your tests here
        XCTAssert(booleanResponseDto.result == false, "Server should return false for username: notexists")
    }

    static let allTests = [
        ("testUserNameValidationShouldReturnTrueIfUserNameExists", testUserNameValidationShouldReturnTrueIfUserNameExists),
        ("testUserNameValidationShouldReturnFalseIfUserNameNotExists", testUserNameValidationShouldReturnFalseIfUserNameNotExists)
    ]
}
