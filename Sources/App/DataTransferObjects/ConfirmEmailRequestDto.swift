//
//  ConfirmEmailRequestDto.swift
//  App
//
//  Created by Marcin Czachurski on 28/10/2018.
//

import Vapor

/// Class for email confirmation process.
final class ConfirmEmailRequestDto {

    var id: UUID
    var confirmationGuid: String

    init(id: UUID, confirmationGuid: String) {
        self.id = id
        self.confirmationGuid = confirmationGuid
    }
}


/// Allows `ConfirmEmailRequestDto` to be encoded to and decoded from HTTP messages.
extension ConfirmEmailRequestDto: Content { }
