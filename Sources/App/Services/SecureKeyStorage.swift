//
//  JWTSecureKeyStorage.swift
//  App
//
//  Created by Marcin Czachurski on 28/10/2018.
//

import Foundation
import Vapor

struct SecureKeyStorage: Service {
    let secureKey: String
}
