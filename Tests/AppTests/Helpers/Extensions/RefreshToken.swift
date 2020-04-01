@testable import App
import Vapor

/*
extension RefreshToken {

    static func get(on application: Application, token: String) throws -> RefreshToken {
        let connection = try application.newConnection(to: .psql).wait()
        guard let refreshToken = try RefreshToken.query(on: connection).filter(\.token == token).first().wait() else {
            throw SharedApplicationError.unwrap
        }

        return refreshToken
    }

    func update(on application: Application) throws {
        let connection = try application.newConnection(to: .psql).wait()
        _ = try self.save(on: connection).wait()
    }
}
*/
