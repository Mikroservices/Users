import Vapor
import Foundation
import JWT

public struct ApplicationSettings {
    public let emailServiceAddress: String?
    public let isRecaptchaEnabled: Bool
    public let recaptchaKey: String
    public let jwtPrivateKey: String
    
    init(application: Application,
         emailServiceAddress: String? = nil,
         isRecaptchaEnabled: Bool = false,
         recaptchaKey: String = "",
         jwtPrivateKey: String = ""
    ) {
        self.emailServiceAddress = emailServiceAddress
        self.isRecaptchaEnabled = isRecaptchaEnabled
        self.recaptchaKey = recaptchaKey
        self.jwtPrivateKey = jwtPrivateKey
        
        if jwtPrivateKey != "" {
            do {
                guard let privateKey = application.settings.configuration.jwtPrivateKey.data(using: .utf8) else {
                    throw Abort(.internalServerError, reason: "Private key is not configured in database.")
                }
                
                let rsaKey: RSAKey = try .private(pem: privateKey)
                application.jwt.signers.use(.rs512(key: rsaKey))
            } catch {
                fatalError("JWT token is invalid")
            }
        }
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
