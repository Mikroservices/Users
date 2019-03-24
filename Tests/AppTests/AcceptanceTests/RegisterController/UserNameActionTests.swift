@testable import App
import XCTest
import Vapor
import XCTest
import FluentPostgreSQL

final class UserNameActionTests: XCTestCase {

    func testUserNameValidationShouldReturnTrueIfUserNameExists() throws {

        // Arrange.
        try User.create(on: SharedApplication.application(),
                        userName: "johndoe",
                        email: "johndoe@testemail.com",
                        name: "John Doe")

        // Act.
        let booleanResponseDto = try SharedApplication.application()
            .getResponse(to: "/register/userName/johndoe", decodeTo: BooleanResponseDto.self)

        // Assert.
        XCTAssert(booleanResponseDto.result, "Server should return true for username: johndoe.")
    }

    func testUserNameValidationShouldReturnFalseIfUserNameNotExists() throws {

        // Arrange.
        let url = "/register/userName/notexists"

        // Act.
        let booleanResponseDto = try SharedApplication.application()
            .getResponse(to: url, decodeTo: BooleanResponseDto.self)

        // Assert.
        XCTAssert(booleanResponseDto.result == false, "Server should return false for username: notexists.")
    }

    static let allTests = [
        ("testUserNameValidationShouldReturnTrueIfUserNameExists", testUserNameValidationShouldReturnTrueIfUserNameExists),
        ("testUserNameValidationShouldReturnFalseIfUserNameNotExists", testUserNameValidationShouldReturnFalseIfUserNameNotExists)
    ]
}
