import Fluent
import Vapor

final class Setting: Model {
    static let schema = "Settings"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "key")
    var key: String
    
    @Field(key: "value")
    var value: String

    init() { }
    
    init(id: UUID? = nil,
         key: String,
         value: String
    ) {
        self.id = id
        self.key = key
        self.value = value
    }
}

/// Allows `Setting` to be encoded to and decoded from HTTP messages.
extension Setting: Content { }

public enum SettingKey: String {
    case jwtPrivateKey
    case emailServiceAddress
    case isRecaptchaEnabled
    case recaptchaKey
}

extension Array where Element:Setting {
    func getSetting(_ key: SettingKey) -> Setting? {
        for item in self {
            if item.key == key.rawValue {
                return item
            }
        }
        
        return nil
    }
    
    func getInt(_ key: SettingKey) -> Int? {
        guard let setting = self.getSetting(key) else {
            return nil
        }

        return Int(setting.value)
    }

    func getString(_ key: SettingKey) -> String? {
        return self.getSetting(key)?.value
    }

    func getBool(_ key: SettingKey) -> Bool? {
        guard let setting = self.getSetting(key) else {
            return nil
        }

        return Int(setting.value) ?? 0 == 1
    }
}
