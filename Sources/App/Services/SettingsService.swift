//
//  Settings.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 20/03/2019.
//

import Vapor

public enum SettingKey: String {
    case jwtPrivateKey
    case emailServiceAddress
    case isRecaptchaEnabled
    case recaptchaKey
}

protocol SettingsServiceType: Service {
    func get(on request: Request) throws -> Future<Configuration>
}

final class SettingsService: SettingsServiceType {

    private var configuration: Configuration?

    func get(on request: Request) throws -> Future<Configuration> {

        if let unwrapedConfiguration = self.configuration {
            return Future.map(on: request) { return unwrapedConfiguration }
        }

        let logger = try request.make(Logger.self)
        logger.info("Downloading application settings from database")

        return Setting.query(on: request).all().map(to: Configuration.self) { settings in
            let configuration = Configuration(settings: settings)
            self.configuration = configuration

            return configuration
        }
    }
}
