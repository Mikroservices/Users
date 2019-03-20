//
//  CaptchaService.swift
//  Users
//
//  Created by Marcin Czachurski on 20/03/2019.
//

import Vapor
import Recaptcha

final class CaptchaService: ServiceType {

    private let googleCaptcha: GoogleCaptcha?

    static func makeService(for container: Container) throws -> CaptchaService {

        let settingsService = try container.make(SettingsService.self)
        guard let isRecaptchaEnabled = settingsService.getBool(.isRecaptchaEnabled) else {
            throw Abort(.internalServerError, reason: "Recaptcha enabled/disabled variable is not set in database.")
        }

        if isRecaptchaEnabled {
            guard let recaptchaKey = settingsService.getString(.recaptchaKey) else {
                throw Abort(.internalServerError, reason: "Recaptcha key variable is not set in database.")
            }

            let captchaConfig = GoogleCaptchaConfig(secretKey: recaptchaKey)

            let googleCaptcha = try GoogleCaptcha(config: captchaConfig, client: container.make(Client.self))
            return CaptchaService(googleCaptcha)
        }

        return CaptchaService()
    }

    private init(_ googleCaptcha: GoogleCaptcha? = nil) {
        self.googleCaptcha = googleCaptcha
    }

    public func validate(on request: Request, captchaFormResponse: String) throws -> Future<Bool> {
        if let captcha = self.googleCaptcha {
            return try captcha.validate(captchaFormResponse: captchaFormResponse)
        }

        return Future.map(on: request) { return true }
    }
}