import Vapor

final class ForgotPasswordRequestDto {

    var email: String

    init(email: String) {
        self.email = email
    }
}

extension ForgotPasswordRequestDto: Content { }
