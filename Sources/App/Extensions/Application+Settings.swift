import Vapor

public struct ApplicationSettings {
    public let emailServiceAddress: String?
    public let isRecaptchaEnabled: Bool
    public let recaptchaKey: String
    public let eventsToStore: [EventType]
    public let corsOrigin: String?
    
    init(application: Application,
         emailServiceAddress: String? = nil,
         isRecaptchaEnabled: Bool = false,
         recaptchaKey: String = "",
         eventsToStore: String = "",
         corsOrigin: String? = nil
    ) {
        self.emailServiceAddress = emailServiceAddress
        self.isRecaptchaEnabled = isRecaptchaEnabled
        self.recaptchaKey = recaptchaKey
        self.corsOrigin = corsOrigin
        
        var eventsArray: [EventType] = []
        EventType.allCases.forEach {
            if eventsToStore.contains($0.rawValue) {
                eventsArray.append($0)
            }
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
