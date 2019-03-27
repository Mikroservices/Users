@testable import App
import XCTest
import Vapor
import XCTest
import FluentPostgreSQL

final class EmailActionTests: XCTestCase {

    func testEmailValidationShouldReturnTrueIfEmailExists() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "tomsmith",
                            email: "tomsmith@testemail.com",
                            name: "Tom Smith")

        // Act.
        let booleanResponseDto = try SharedApplication.application()
            .getResponse(to: "/register/email/tomsmith@testemail.com", decodeTo: BooleanResponseDto.self)

        // Assert.
        XCTAssert(booleanResponseDto.result, "Server should return true for email: tomsmith@testemail.com.")
    }

    func testEmailValidationShouldReturnFalseIfEmailNotExists() throws {

        // Arrange.
        let url = "/register/email/notexists@testemail.com"

        // Act.
        let booleanResponseDto = try SharedApplication.application()
            .getResponse(to: url, decodeTo: BooleanResponseDto.self)

        // Assert.
        XCTAssert(booleanResponseDto.result == false, "Server should return false for email: notexists@testemail.com.")
    }

    static let allTests = [
        ("testEmailValidationShouldReturnTrueIfEmailExists", testEmailValidationShouldReturnTrueIfEmailExists),
        ("testEmailValidationShouldReturnFalseIfEmailNotExists", testEmailValidationShouldReturnFalseIfEmailNotExists)
    ]
}
