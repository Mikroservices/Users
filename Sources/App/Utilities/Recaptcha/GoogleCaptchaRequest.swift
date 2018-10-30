//
//  GoogleCaptchaRequest.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 30/10/2018.
//

import Foundation
import Vapor

struct GoogleCaptchaRequest: Content {
    var secret: String
    var response: String
}
