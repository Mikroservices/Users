//
//  JWTSecureKeyStorage.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 28/10/2018.
//

import Foundation
import Vapor

struct SettingsStorage: Service {
    let privateKey: String
    let emailServiceAddress: String
}
