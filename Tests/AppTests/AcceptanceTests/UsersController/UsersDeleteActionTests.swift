@testable import App
import XCTest
import XCTVapor
import Fluent

final class UsersDeleteActionTests: XCTestCase {
    
    func testAccountShouldBeDeletedForAuthorizedUser() throws {

        // Arrange.
        _ = try User.create(userName: "zibibonjek",
                            email: "zibibonjek@testemail.com",
                            name: "Zibi Bonjek")
        
        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "zibibonjek", password: "p@ssword"),
            to: "/users/@zibibonjek",
            method: .DELETE
        )

        // Assert.
        XCTAssertEqual(response.status, HTTPResponseStatus.ok, "Response http status code should be ok (200).")
        let userFromDb = try? User.query(on: SharedApplication.application().db).filter(\.$userName == "zibibonjek").first().wait()
        XCTAssert(userFromDb == nil, "User should be deleted.")
    }

    func testAccountShouldNotBeDeletedIfUserIsNotAuthorized() throws {

        // Arrange.
        _ = try User.create(userName: "victoriabonjek",
                            email: "victoriabonjek@testemail.com",
                            name: "Victoria Bonjek")

        // Act.
        let response = try SharedApplication.application()
            .sendRequest(to: "/users/@victoriabonjek", method: .DELETE)

        // Assert.
        XCTAssertEqual(response.status, HTTPResponseStatus.unauthorized, "Response http status code should be unauthorized (401).")
    }

    func testAccountShouldNotDeletedWhenUserTriesToDeleteNotHisAccount() throws {

        // Arrange.
        _ = try User.create(userName: "martabonjek",
                            email: "martabonjek@testemail.com",
                            name: "Marta Bonjek")
        
        _ = try User.create(userName: "kingabonjek",
                            email: "kingabonjek@testemail.com",
                            name: "Kinga Bonjek")

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "martabonjek", password: "p@ssword"),
            to: "/users/@kingabonjek",
            method: .DELETE
        )

        // Assert.
        XCTAssertEqual(response.status, HTTPResponseStatus.forbidden, "Response http status code should be forbidden (403).")
    }

    func testForbiddenShouldBeReturnedIfAccountNotExists() throws {

        // Arrange.
        _ = try User.create(userName: "henrybonjek",
                            email: "henrybonjek@testemail.com",
                            name: "Henry Bonjek")

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "henrybonjek", password: "p@ssword"),
            to: "/users/@notexists",
            method: .DELETE
        )

        // Assert.
        XCTAssertEqual(response.status, HTTPResponseStatus.forbidden, "Response http status code should forbidden (403).")
    }

    static let allTests = [
        ("testAccountShouldBeDeletedForAuthorizedUser", testAccountShouldBeDeletedForAuthorizedUser),
        ("testAccountShouldNotBeDeletedIfUserIsNotAuthorized", testAccountShouldNotBeDeletedIfUserIsNotAuthorized),
        ("testAccountShouldNotDeletedWhenUserTriesToDeleteNotHisAccount", testAccountShouldNotDeletedWhenUserTriesToDeleteNotHisAccount),
        ("testForbiddenShouldBeReturnedIfAccountNotExists", testForbiddenShouldBeReturnedIfAccountNotExists)
    ]
}

