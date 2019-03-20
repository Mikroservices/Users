//
//  Settings.swift
//  Users
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

final class SettingsService: ServiceType {

    fileprivate static var settings: [String: String] = [:]

    static func makeService(for worker: Container) throws -> SettingsService {
        return SettingsService()
    }

    public func configure(settings: [Setting]) {

        if (SettingsService.settings.count > 0) {
            return
        }

        for setting in settings {
            SettingsService.settings[setting.key] = setting.value
        }
    }

    public func getInt(_ key: SettingKey) -> Int? {
        guard let value = SettingsService.settings[key.rawValue] else {
            return nil
        }

        return Int(value)
    }

    public func getString(_ key: SettingKey) -> String? {
        guard let value = SettingsService.settings[key.rawValue] else {
            return nil
        }

        return value
    }

    public func getBool(_ key: SettingKey) -> Bool? {
        guard let value = SettingsService.settings[key.rawValue] else {
            return nil
        }

        return Int(value) ?? 0 == 1
    }
}