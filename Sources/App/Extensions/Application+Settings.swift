import Vapor

public struct ApplicationSettings {
    public let emailServiceAddress: String?
    public let isRecaptchaEnabled: Bool
    public let recaptchaKey: String
    public let eventsToStore: [EventType]
    
    init(application: Application,
         emailServiceAddress: String? = nil,
         isRecaptchaEnabled: Bool = false,
         recaptchaKey: String = "",
         eventsToStore: String = ""
    ) {
        self.emailServiceAddress = emailServiceAddress
        self.isRecaptchaEnabled = isRecaptchaEnabled
        self.recaptchaKey = recaptchaKey
        
        var eventsArray: [EventType] = []
        if eventsToStore.contains(EventType.login.rawValue) {
            eventsArray = [.login]
        }
        
        self.eventsToStore = eventsArray
    }
}


extension Application {
    public var settings: Settings {
        .init(application: self)
    }

    public struct Settings {
        let application: Application

        struct ConfigurationKey: StorageKey {
            typealias Value = ApplicationSettings
        }

        public var configuration: ApplicationSettings {
            get {
                self.application.storage[ConfigurationKey.self] ?? .init(application: application)
            }
            nonmutating set {
                self.application.storage[ConfigurationKey.self] = newValue
            }
        }
    }
}
