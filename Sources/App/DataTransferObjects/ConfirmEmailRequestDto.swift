//
//  ConfirmEmailRequestDto.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 28/10/2018.
//

import Vapor

final class ConfirmEmailRequestDto {

    var id: UUID
    var confirmationGuid: String

    init(id: UUID, confirmationGuid: String) {
        self.id = id
        self.confirmationGuid = confirmationGuid
    }
}

extension ConfirmEmailRequestDto: Content { }
