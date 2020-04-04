import Vapor

struct EmailDto {
    var to: EmailAddressDto
    var title: String
    var body: String
    var from: EmailAddressDto?
    var replyTo: EmailAddressDto?
}

extension EmailDto: Content { }
