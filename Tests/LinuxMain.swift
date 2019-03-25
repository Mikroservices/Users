import XCTest
@testable import AppTests

XCTMain([
    testCase(ConfirmActionTests.allTests),
    testCase(EmailActionTests.allTests),
    testCase(RegisterActionTests.allTests),
    testCase(UserNameActionTests.allTests),
    testCase(LoginActionTests.allTests)
])