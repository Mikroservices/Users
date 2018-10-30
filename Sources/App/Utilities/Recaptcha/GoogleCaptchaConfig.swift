//
//  GoogleCaptchaConfig.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 30/10/2018.
//

import Foundation

public struct GoogleCaptchaConfig {
    let secretKey: String
    
    public init(secretKey: String) {
        self.secretKey = secretKey
    }
}
