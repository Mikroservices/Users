import Vapor

final class ForgotPasswordConfirmationRequestDto {

    var forgotPasswordGuid: String
    var password: String

    init(forgotPasswordGuid: String, password: String) {
        self.forgotPasswordGuid = forgotPasswordGuid
        self.password = password
    }
}

extension ForgotPasswordConfirmationRequestDto: Content { }

extension ForgotPasswordConfirmationRequestDto: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("password", as: String.self, is: .count(8...32) && .password)
    }
}
