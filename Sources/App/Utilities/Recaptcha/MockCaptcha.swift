//
//  MockCaptcha.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 30/10/2018.
//

import Foundation
import Vapor

public struct MockCaptcha: Captcha {

    private let container: Container

    init(container: Container) {
        self.container = container
    }

    public func validate(captchaFormResponse: String) throws -> EventLoopFuture<Bool> {
        return self.container.eventLoop.newSucceededFuture(result: true)
    }
}
