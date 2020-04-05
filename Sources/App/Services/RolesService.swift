import Vapor
import Fluent

extension Application.Services {
    struct RolesServiceKey: StorageKey {
        typealias Value = RolesServiceType
    }

    var rolesService: RolesServiceType {
        get {
            self.application.storage[RolesServiceKey.self] ?? RolesService()
        }
        nonmutating set {
            self.application.storage[RolesServiceKey.self] = newValue
        }
    }
}

protocol RolesServiceType {
    func getDefault(on request: Request) -> EventLoopFuture<[Role]>
    func validateCode(on request: Request, code: String, roleId: UUID?) -> EventLoopFuture<Void>
}

final class RolesService: RolesServiceType {

    func getDefault(on request: Request) -> EventLoopFuture<[Role]> {
        return Role.query(on: request.db).filter(\.$isDefault == true).all()
    }
    
    func validateCode(on request: Request, code: String, roleId: UUID?) -> EventLoopFuture<Void> {
        if let unwrapedRoleId = roleId {
            return Role.query(on: request.db).group(.and) { verifyCodeGroup in
                verifyCodeGroup.filter(\.$code == code)
                verifyCodeGroup.filter(\.$id != unwrapedRoleId)
            }.first().flatMap { role -> EventLoopFuture<Void> in
                if role != nil {
                    return request.fail(RoleError.roleWithCodeExists)
                }
                
                return request.success()
            }
        } else {
            return Role.query(on: request.db).filter(\.$code == code).first().flatMap { role -> EventLoopFuture<Void> in
                if role != nil {
                    return request.fail(RoleError.roleWithCodeExists)
                }
                
                return request.success()
            }
        }
    }
}



