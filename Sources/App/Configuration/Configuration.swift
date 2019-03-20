//
//  Configuration.swift
//  App
//
//  Created by Marcin Czachurski on 20/03/2019.
//

import Foundation

class Configuration {
    private var settings: [String: String] = [:]

    init(settings: [Setting]) {
        for setting in settings {
            self.settings[setting.key] = setting.value
        }
    }

    func getInt(_ key: SettingKey) -> Int? {
        guard let value = self.settings[key.rawValue] else {
            return nil
        }

        return Int(value)
    }

    func getString(_ key: SettingKey) -> String? {
        return self.settings[key.rawValue]
    }

    func getBool(_ key: SettingKey) -> Bool? {
        guard let value = self.settings[key.rawValue] else {
            return nil
        }

        return Int(value) ?? 0 == 1
    }
}
