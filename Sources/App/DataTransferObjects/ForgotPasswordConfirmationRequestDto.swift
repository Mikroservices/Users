import Vapor

final class ForgotPasswordConfirmationRequestDto: Reflectable {

    var forgotPasswordGuid: String
    var password: String

    init(forgotPasswordGuid: String, password: String) {
        self.forgotPasswordGuid = forgotPasswordGuid
        self.password = password
    }
}

extension ForgotPasswordConfirmationRequestDto: Content { }

extension ForgotPasswordConfirmationRequestDto: Validatable {

    /// See `Validatable`.
    static func validations() throws -> Validations<ForgotPasswordConfirmationRequestDto> {
        var validations = Validations(ForgotPasswordConfirmationRequestDto.self)

        try validations.add(\.password, .count(8...32) && .password)

        return validations
    }
}
