import Vapor

final class UserDto: Reflectable {

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

    /// See `Validatable`.
    static func validations() throws -> Validations<UserDto> {
        var validations = Validations(UserDto.self)

        try validations.add(\.name, .count(...50) || .nil)
        try validations.add(\.location, .count(...50) || .nil)
        try validations.add(\.website, .count(...50) || .nil)
        try validations.add(\.bio, .count(...200) || .nil)

        return validations
    }
}
