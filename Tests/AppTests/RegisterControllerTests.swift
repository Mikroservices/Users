@testable import App
import XCTest
import Vapor
import XCTest
import FluentPostgreSQL

final class RegisterControllerTests: XCTestCase {

    func testUserNameValidationShouldReturnTrueIfUserNameExists() throws {
        // Create a Responder type; this is what responds to your requests.
        let responder = try SharedApplication.application().make(Responder.self)

        // Send a GET HTTPRequest to /register/userName/mczachurski
        let request = HTTPRequest(method: .GET, url: URL(string: "/register/userName/mczachurski")!)
        let wrappedRequest = Request(http: request, using: try SharedApplication.application())

        // Send the request and get the response.
        let response = try responder.respond(to: wrappedRequest).wait()

        // Decode the response data.
        let data = response.http.body.data
        let booleanResponseDto = try JSONDecoder().decode(BooleanResponseDto.self, from: data!)

        // add your tests here
        XCTAssert(booleanResponseDto.result, "Server should return true for username: mczachurski")
    }

    func testUserNameValidationShouldReturnFalseIfUserNameNotExists() throws {
        // Create a Responder type; this is what responds to your requests.
        let responder = try SharedApplication.application().make(Responder.self)

        // Send a GET HTTPRequest to /register/userName/mczachurski
        let request = HTTPRequest(method: .GET, url: URL(string: "/register/userName/notexists")!)
        let wrappedRequest = Request(http: request, using: try SharedApplication.application())

        // Send the request and get the response.
        let response = try responder.respond(to: wrappedRequest).wait()

        // Decode the response data.
        let data = response.http.body.data
        let booleanResponseDto = try JSONDecoder().decode(BooleanResponseDto.self, from: data!)

        // add your tests here
        XCTAssert(booleanResponseDto.result == false, "Server should return false for username: notexists")
    }

    static let allTests = [
        ("testUserNameValidationShouldReturnTrueIfUserNameExists", testUserNameValidationShouldReturnTrueIfUserNameExists),
        ("testUserNameValidationShouldReturnFalseIfUserNameNotExists", testUserNameValidationShouldReturnFalseIfUserNameNotExists)
    ]
}
