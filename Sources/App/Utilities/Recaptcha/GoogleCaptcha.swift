//
//  GoogleCaptcha.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 30/10/2018.
//

import Foundation
import Vapor

public class GoogleCaptcha: Captcha {
    private let config: GoogleCaptchaConfig
    private let client: Client
    private let endpoint = "https://www.google.com/recaptcha/api/siteverify"
    
    public init(config: GoogleCaptchaConfig, client: Client) {
        self.config = config
        self.client = client
    }
    
    public func validate(captchaFormResponse: String) throws -> Future<Bool> {
        let requestData = GoogleCaptchaRequest(secret: config.secretKey, response: captchaFormResponse)
        
        let request = client.post(endpoint) { req in
            try req.content.encode(requestData, as: .urlEncodedForm)
        }
        
        return request.flatMap { response in
            return try response.content.decode(GoogleCaptchaResponse.self)
        }.map { response in
            return response.success ?? false
        }
    }
}
