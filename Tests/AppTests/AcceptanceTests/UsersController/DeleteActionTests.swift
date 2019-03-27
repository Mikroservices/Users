@testable import App
import XCTest
import Vapor
import XCTest
import FluentPostgreSQL

final class DeleteActionTests: XCTestCase {
    
    func testUserShouldBeDeletedForAuthorizedUser() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "zibibonjek",
                            email: "zibibonjek@testemail.com",
                            name: "Zibi Bonjek")

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "zibibonjek", password: "p@ssword"),
            to: "/users/@zibibonjek",
            method: .DELETE
        )

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.ok, "Response http status code should be ok (200).")
        let user = try? User.get(on: SharedApplication.application(), userName: "zibibonjek")
        XCTAssert(user == nil, "User should be deleted.")
    }

    func testUnauthorizedStatusCodeShouldBeReturnedForUnauthorizedUser() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "victoriabonjek",
                            email: "victoriabonjek@testemail.com",
                            name: "Victoria Bonjek")

        // Act.
        let response = try SharedApplication.application()
            .sendRequest(to: "/users/@victoriabonjek", method: .DELETE)

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.unauthorized, "Response http status code should be unauthorized (401).")
    }

    func testForbiddenStatusCodeShouldBeReturnedForOtherUserData() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "martabonjek",
                            email: "martabonjek@testemail.com",
                            name: "Marta Bonjek")

        _ = try User.create(on: SharedApplication.application(),
                            userName: "kingabonjek",
                            email: "kingabonjek@testemail.com",
                            name: "Kinga Bonjek")

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "martabonjek", password: "p@ssword"),
            to: "/users/@kingabonjek",
            method: .DELETE
        )

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.forbidden, "Response http status code should be forbidden (403).")
    }

    func testNotFoundStatusCodeShouldBeReturnedIfUserNotExists() throws {

        // Arrange.
        _ = try User.create(on: SharedApplication.application(),
                            userName: "henrybonjek",
                            email: "henrybonjek@testemail.com",
                            name: "Henry Bonjek")

        // Act.
        let response = try SharedApplication.application().sendRequest(
            as: .user(userName: "henrybonjek", password: "p@ssword"),
            to: "/users/@notexists",
            method: .DELETE
        )

        // Assert.
        XCTAssertEqual(response.http.status, HTTPResponseStatus.notFound, "Response http status code should be not found (404).")
    }

    static let allTests = [
        ("testUserShouldBeDeletedForAuthorizedUser", testUserShouldBeDeletedForAuthorizedUser),
        ("testUnauthorizedStatusCodeShouldBeReturnedForUnauthorizedUser", testUnauthorizedStatusCodeShouldBeReturnedForUnauthorizedUser),
        ("testForbiddenStatusCodeShouldBeReturnedForOtherUserData", testForbiddenStatusCodeShouldBeReturnedForOtherUserData),
        ("testNotFoundStatusCodeShouldBeReturnedIfUserNotExists", testNotFoundStatusCodeShouldBeReturnedIfUserNotExists)
    ]
}
