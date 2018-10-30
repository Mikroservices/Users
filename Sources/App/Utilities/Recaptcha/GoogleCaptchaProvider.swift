//
//  GoogleCaptchaProvider.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 30/10/2018.
//

import Foundation
import Vapor

public struct GoogleCaptchaProvider: Provider {
    
    private let config: GoogleCaptchaConfig
    
    public init(config: GoogleCaptchaConfig) {
        self.config = config
    }
    
    public func register(_ services: inout Services) throws {
        services.register(Captcha.self) { container -> GoogleCaptcha in
            return try GoogleCaptcha(config: self.config, client: container.make(Client.self))
        }
    }
    
    public func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        return .done(on: container)
    }
}
