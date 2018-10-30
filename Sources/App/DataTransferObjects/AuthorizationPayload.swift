//
//  JWTPayload.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 25/10/2018.
//

import Foundation
import JWT

struct AuthorizationPayload: JWTPayload {
    var id: UUID?
    var name: String
    var email: String
    var exp: Date

    func verify(using signer: JWTSigner) throws {
        // nothing to verify
    }
}
