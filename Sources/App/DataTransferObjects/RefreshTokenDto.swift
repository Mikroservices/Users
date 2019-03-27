import Vapor

final class RefreshTokenDto {

    var refreshToken: String

    init(refreshToken: String) {
        self.refreshToken = refreshToken
    }
}

extension RefreshTokenDto: Content { }
