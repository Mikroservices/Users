import Vapor

final class UserRoleDto {

    var userId: UUID
    var roleId: UUID

    init(userId: UUID,
         roleId: UUID) {
        self.userId = userId
        self.roleId = roleId
    }
}

extension UserRoleDto: Content { }
