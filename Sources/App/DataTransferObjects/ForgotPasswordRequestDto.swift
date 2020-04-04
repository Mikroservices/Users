import Vapor

struct ForgotPasswordRequestDto {
    var email: String
}

extension ForgotPasswordRequestDto: Content { }
