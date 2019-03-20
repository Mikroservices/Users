//
//  CaptchaService.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 20/03/2019.
//

import Vapor
import Recaptcha

final class CaptchaService: ServiceType {

    private let googleCaptcha: GoogleCaptcha?

    static func makeService(for container: Container) throws -> CaptchaService {
        return CaptchaService()
    }

    private init(_ googleCaptcha: GoogleCaptcha? = nil) {
        self.googleCaptcha = googleCaptcha
    }

    public func validate(on request: Request, captchaFormResponse: String) throws -> Future<Bool> {

        let settingsService = try request.make(SettingsService.self)

        return try settingsService.get(on: request).flatMap(to: Bool.self) { configuration in
            guard let isRecaptchaEnabled = configuration.getBool(.isRecaptchaEnabled) else {
                throw Abort(.internalServerError, reason: "Recaptcha enabled/disabled variable is not set in database.")
            }

            guard let recaptchaKey = configuration.getString(.recaptchaKey) else {
                throw Abort(.internalServerError, reason: "Recaptcha key variable is not set in database.")
            }

            if isRecaptchaEnabled {
                let captchaConfig = GoogleCaptchaConfig(secretKey: recaptchaKey)
                let googleCaptcha = try GoogleCaptcha(config: captchaConfig, client: request.make(Client.self))

                return try googleCaptcha.validate(captchaFormResponse: captchaFormResponse)
            }

            let logger = try request.make(Logger.self)
            logger.info("Recaptcha is disabled all request are allowed.")

            return Future.map(on: request) { return true }
        }
    }
}
