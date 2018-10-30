//
//  Captcha.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 30/10/2018.
//

import Foundation
import Vapor

public protocol Captcha: Service {
    func validate(captchaFormResponse: String) throws -> Future<Bool>
}
