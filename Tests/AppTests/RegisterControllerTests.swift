@testable import App
import XCTest
import Vapor
import XCTest
import FluentPostgreSQL

final class RegisterControllerTests: XCTestCase {

    func testUserAccountShouldBeCreatedForValidUserData() throws {

        // Arrange.
        let userDto = UserDto(userName: "wiktor4",
                              email: "wiktor4@notexists.xxx.pl",
                              gravatarHash: "",
                              name: "Wiktor Jakis",
                              password: "Crusader1",
                              bio: "",
                              location: "",
                              website: "",
                              securityToken: "")

        // Act.
        let createdUserDto = try SharedApplication.application().getResponse(to: "/register", method: .POST, data: userDto, decodeTo: UserDto.self)

        // Assert.
        XCTAssert(createdUserDto.id != nil, "User wasn't created.")
    }

    func testUserNameValidationShouldReturnTrueIfUserNameExists() throws {

        // Arrange.
        let url = "/register/userName/mczachurski"

        // Act.
        let booleanResponseDto = try SharedApplication.application()
            .getResponse(to: url, decodeTo: BooleanResponseDto.self)

        // Assert.
        XCTAssert(booleanResponseDto.result, "Server should return true for username: mczachurski.")
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
        ("testUserAccountShouldBeCreatedForValidUserData", testUserAccountShouldBeCreatedForValidUserData),
        ("testUserNameValidationShouldReturnTrueIfUserNameExists", testUserNameValidationShouldReturnTrueIfUserNameExists),
        ("testUserNameValidationShouldReturnFalseIfUserNameNotExists", testUserNameValidationShouldReturnFalseIfUserNameNotExists)
    ]
}
