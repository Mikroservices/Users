//
//  MockCaptchaProvider.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 30/10/2018.
//

import Foundation
import Vapor

public struct MockCaptchaProvider: Provider {

    public func register(_ services: inout Services) throws {
        services.register(Captcha.self) { container -> MockCaptcha in
            return MockCaptcha(container: container)
        }
    }

    public func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        return .done(on: container)
    }
}
