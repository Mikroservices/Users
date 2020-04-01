@testable import App
import Vapor

/*
extension Role {

    static func create(on application: Application,
                       name: String,
                       code: String,
                       description: String,
                       hasSuperPrivileges: Bool = false,
                       isDefault: Bool = false) throws -> Role {

        let connection = try application.newConnection(to: .psql).wait()
        let role = Role(name: name,
                        code: code,
                        description: description,
                        hasSuperPrivileges: hasSuperPrivileges,
                        isDefault: isDefault)

        _ = try role.save(on: connection).wait()

        return role
    }

    static func get(on application: Application, name: String) throws -> Role {
        let connection = try application.newConnection(to: .psql).wait()
        guard let role = try Role.query(on: connection).filter(\.name == name).first().wait() else {
            throw SharedApplicationError.unwrap
        }

        return role
    }
}
*/
