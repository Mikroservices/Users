//
//  EmailDto.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 04/11/2018.
//

import Vapor

/// A single entry of a Email.
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

/// Allows `EmailDto` to be encoded to and decoded from HTTP messages.
extension EmailDto: Content { }
