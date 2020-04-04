@testable import App
import Vapor
import Fluent

extension Role {

    static func create(name: String,
                       code: String,
                       description: String,
                       hasSuperPrivileges: Bool = false,
                       isDefault: Bool = false) throws -> Role {

        let role = Role(role: name,
                        code: code,
                        description: description,
                        hasSuperPrivileges: hasSuperPrivileges,
                        isDefault: isDefault)

        try role.save(on: SharedApplication.application().db).wait()

        return role
    }

    static func get(role: String) throws -> Role {
        guard let role = try Role.query(on: SharedApplication.application().db).filter(\.$role == role).first().wait() else {
            throw SharedApplicationError.unwrap
        }

        return role
    }
}
