@testable import App
import XCTest
import XCTVapor
import Fluent

final class ConfirmActionTests: XCTestCase {

    func testAccountShouldBeConfirmedWithCorrectConfirmationGuid() throws {

        // Arrange.
        _ = try User.create(userName: "samanthasmith",
                            email: "samanthasmith@testemail.com",
                            name: "Samantha Smith",
                            emailWasConfirmed: false)

        guard let user = try User.query(on: SharedApplication.application().db).filter(\.$userName == "samanthasmith").first().wait() else {
            XCTAssertFalse(true, "User not exists")
            return
        }
        let confirmEmailRequestDto = ConfirmEmailRequestDto(id: user.id!, confirmationGuid: user.emailConfirmationGuid)

        // Act.
        let response = try SharedApplication.application().sendRequest(to: "/register/confirm", method: .POST, body: confirmEmailRequestDto)

        // Assert.
        let userAfterRequest = try User.query(on: SharedApplication.application().db).filter(\.$userName == "samanthasmith").first().wait()
        XCTAssertEqual(response.status, HTTPResponseStatus.ok, "Response http status code should be ok (200).")
        XCTAssertEqual(userAfterRequest?.emailWasConfirmed, true, "Email is not confirmed.")
    }

    func testAccountShouldNotBeConfirmedWithIncorrectConfirmationGuid() throws {

        // Arrange.
        _ = try User.create(userName: "eriksmith",
                            email: "eriksmith@testemail.com",
                            name: "Erik Smith",
                            emailWasConfirmed: false)
        
        guard let user = try User.query(on: SharedApplication.application().db).filter(\.$userName == "eriksmith").first().wait() else {
            XCTAssertFalse(true, "User not exists")
            return
        }
        let confirmEmailRequestDto = ConfirmEmailRequestDto(id: user.id!, confirmationGuid: UUID().uuidString)

        // Act.
        let response = try SharedApplication.application().sendRequest(to: "/register/confirm", method: .POST, body: confirmEmailRequestDto)

        // Assert.s
        let userAfterRequest = try User.query(on: SharedApplication.application().db).filter(\.$userName == "eriksmith").first().wait()
        XCTAssertEqual(response.status, HTTPResponseStatus.badRequest, "Response http status code should be ok (200).")
        XCTAssertEqual(userAfterRequest?.emailWasConfirmed, false, "Email is confirmed.")
    }

    static let allTests = [
        ("testAccountShouldBeConfirmedWithCorrectConfirmationGuid", testAccountShouldBeConfirmedWithCorrectConfirmationGuid),
        ("testAccountShouldNotBeConfirmedWithIncorrectConfirmationGuid", testAccountShouldNotBeConfirmedWithIncorrectConfirmationGuid)
    ]
}
