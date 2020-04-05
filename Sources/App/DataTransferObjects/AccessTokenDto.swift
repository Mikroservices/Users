import Vapor

struct AccessTokenDto {
    var userId: UUID?
    var accessToken: String
    var refreshToken: String
}

extension AccessTokenDto: Content { }
