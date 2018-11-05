//
//  EmailAddressDto.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 05/11/2018.
//

import Vapor

/// A single entry of a EmailAddressDto.
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

/// Allows `EmailAddressDto` to be encoded to and decoded from HTTP messages.
extension EmailAddressDto: Content { }
