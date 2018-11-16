//
//  BooleanResponseDto.swift
//  App
//
//  Created by Marcin Czachurski on 15/11/2018.
//

import Vapor

final class BooleanResponseDto {

    var result: Bool

    init(_ result: Bool) {
        self.result = result
    }
}

extension BooleanResponseDto: Content { }
