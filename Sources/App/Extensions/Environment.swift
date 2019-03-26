//
//  Environment.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 20/03/2019.
//

import Foundation
import Vapor

extension Environment {
    static func require(_ key: String) throws -> String {
        guard let value = get(key) else {
            throw Abort(.internalServerError, reason: "Missing environment variable for '\(key)'")
        }

        return value
    }
}