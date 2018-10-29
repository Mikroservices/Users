//
//  ConfirmEmailRequestDto.swift
//  App
//
//  Created by Marcin Czachurski on 28/10/2018.
//

import Vapor

/// Class for email confirmation process.
final class ConfirmEmailRequestDto {

    var id: String
    var confirmationGuid: String

    init(id: String, confirmationGuid: String) {
        self.id = id
        self.confirmationGuid = confirmationGuid
    }
}


/// Allows `ConfirmEmailRequestDto` to be encoded to and decoded from HTTP messages.
extension ConfirmEmailRequestDto: Content { }
