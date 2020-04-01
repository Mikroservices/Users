import Vapor

final class UserDto {

    var id: UUID?
    var userName: String
    var email: String?
    var name: String?
    var bio: String?
    var location: String?
    var website: String?
    var birthDate: Date?
    var gravatarHash: String?

    init(id: UUID? = nil,
         userName: String,
         email: String?,
         gravatarHash: String? = nil,
         name: String? = nil,
         bio: String? = nil,
         location: String? = nil,
         website: String? = nil,
         birthDate: Date? = nil
    ) {
        self.id = id
        self.userName = userName
        self.email = email
        self.gravatarHash = gravatarHash
        self.name = name
        self.bio = bio
        self.location = location
        self.website = website
        self.birthDate = birthDate
    }
}

extension UserDto: Content { }

extension UserDto {
    convenience init(from user: User) {
        self.init(
            id: user.id,
            userName: user.userName,
            email: user.email,
            gravatarHash: user.gravatarHash,
            name: user.name,
            bio: user.bio,
            location: user.location,
            website: user.website,
            birthDate: user.birthDate
        )
    }
}

extension UserDto: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String?.self, is: .count(...50) || .nil)
        validations.add("location", as: String?.self, is: .count(...50) || .nil)
        validations.add("website", as: String?.self, is: .count(...50) || .nil)
        validations.add("bio", as: String?.self, is: .count(...200) || .nil)
    }
}
