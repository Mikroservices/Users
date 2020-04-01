import Vapor

public enum SettingKey: String {
    case jwtPrivateKey
    case emailServiceAddress
    case isRecaptchaEnabled
    case recaptchaKey
}

extension Application.Services {
    struct SettingsServiceKey: StorageKey {
        typealias Value = SettingsServiceType
    }

    var settingsService: SettingsServiceType {
        get {
            self.application.storage[SettingsServiceKey.self] ?? SettingsService()
        }
        nonmutating set {
            self.application.storage[SettingsServiceKey.self] = newValue
        }
    }
}

protocol SettingsServiceType {
    func get(on application: Application) -> EventLoopFuture<Configuration>
}

final class SettingsService: SettingsServiceType {

    func get(on application: Application) -> EventLoopFuture<Configuration> {

        application.logger.info("Downloading application settings from database")

        return Setting.query(on: application.db).all().map { settings in
            let configuration = Configuration(settings: settings)
            return configuration
        }
    }
}
