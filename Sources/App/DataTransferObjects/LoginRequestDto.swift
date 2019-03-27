import Vapor

final class LoginRequestDto {

    var userNameOrEmail: String
    var password: String

    init(userNameOrEmail: String, password: String) {
        self.userNameOrEmail = userNameOrEmail
        self.password = password
    }
}

extension LoginRequestDto: Content { }
