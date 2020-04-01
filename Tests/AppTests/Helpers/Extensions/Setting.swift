@testable import App
import Vapor

/*
extension Setting {
    static func get(on application: Application, key: SettingKey) throws -> Setting {
        let connection = try application.newConnection(to: .psql).wait()
        guard let setting = try Setting.query(on: connection).filter(\.key == key.rawValue).first().wait() else {
            throw SharedApplicationError.unwrap
        }

        return setting
    }
}
*/
