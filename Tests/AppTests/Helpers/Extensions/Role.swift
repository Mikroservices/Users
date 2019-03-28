@testable import App
import Vapor
import FluentPostgreSQL

extension Role {
    static func get(on application: Application, name: String) throws -> Role {
        let connection = try application.newConnection(to: .psql).wait()
        guard let role = try Role.query(on: connection).filter(\.name == name).first().wait() else {
            throw SharedApplicationError.unwrap
        }

        return role
    }
}
