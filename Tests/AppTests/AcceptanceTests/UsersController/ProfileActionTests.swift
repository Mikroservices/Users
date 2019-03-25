//
//  ProfileActionTests.swift
//  AppTests
//
//  Created by Marcin Czachurski on 25/03/2019.
//

@testable import App
import XCTest
import Vapor
import XCTest
import FluentPostgreSQL

final class ProfileActionTests: XCTestCase {

    func testUserProfileShouldBeReturnedForExistingUser() throws {

    }

    func testUserProfileShouldNotBeReturnedForNotExistingUser() throws {

    }

    func testPublicProfileShouldNotContainsSensitiveInformation() throws {

    }

    static let allTests = [
        ("testUserProfileShouldBeReturnedForExistingUser", testUserProfileShouldBeReturnedForExistingUser),
        ("testUserProfileShouldNotBeReturnedForNotExistingUser", testUserProfileShouldNotBeReturnedForNotExistingUser),
        ("testPublicProfileShouldNotContainsSensitiveInformation", testPublicProfileShouldNotContainsSensitiveInformation)
    ]
}
