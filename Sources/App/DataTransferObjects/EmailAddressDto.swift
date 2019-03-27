import Vapor

final class EmailAddressDto {

    var address: String
    var name: String?

    init(address: String,
         name: String? = nil
    ) {
        self.address = address
        self.name = name
    }
}

extension EmailAddressDto: Content { }
