import XCTest
@testable import AppTests

XCTMain([
    testCase(ConfirmActionTests.allTests),
    testCase(EmailActionTests.allTests),
    testCase(RegisterActionTests.allTests),
    testCase(UserNameActionTests.allTests),
    testCase(LoginActionTests.allTests),
    testCase(ChangePasswordActionTests.allTests),
    testCase(TokenActionTests.allTests),
    testCase(ForgotConfirmActionTests.allTests),
    testCase(ProfileActionTests.allTests),
    testCase(UpdateActionTests.allTests),
    testCase(DeleteActionTests.allTests)
])