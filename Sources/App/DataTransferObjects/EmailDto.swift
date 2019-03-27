import Vapor

final class EmailDto {

    var to: EmailAddressDto
    var title: String
    var body: String
    var from: EmailAddressDto?
    var replyTo: EmailAddressDto?

    init(to: EmailAddressDto,
         title: String,
         body: String,
         from: EmailAddressDto? = nil,
         replyTo: EmailAddressDto? = nil
    ) {
        self.to = to
        self.title = title
        self.body = body
        self.from = from
        self.replyTo = replyTo
    }
}

extension EmailDto: Content { }
