import XCTest
@testable import AppTests

XCTMain([

    // Account controller.
    testCase(ChangePasswordActionTests.allTests),
    testCase(LoginActionTests.allTests),
    testCase(RefreshActionTests.allTests),

    // Forgot password controller.
    testCase(ForgotConfirmActionTests.allTests),
    testCase(TokenActionTests.allTests),

    // Register controller.
    testCase(ConfirmActionTests.allTests),
    testCase(EmailActionTests.allTests),
    testCase(RegisterActionTests.allTests),
    testCase(UserNameActionTests.allTests),

    // Roles controller.
    // testCase(RolesCreateActionTests.allTests),
    // testCase(RolesDeleteActionTests.allTests),
    // testCase(RolesListActionTests.allTests),
    // testCase(RolesReadActionTests.allTests),
    // testCase(RolesUpdateActionTests.allTests),

    // User roles controller.
    // testCase(UserRolesConnectActionTests.allTests),
    // testCase(UserRolesDisconnectActionTests.allTests),

    // Users controller.
    testCase(UsersDeleteActionTests.allTests),
    testCase(UsersReadActionTests.allTests),
    testCase(UsersUpdateActionTests.allTests)

])
