import Vapor

final class RegisterUserDto {

    var userName: String
    var email: String
    var password: String
    var name: String?
    var bio: String?
    var location: String?
    var website: String?
    var birthDate: Date?
    var gravatarHash: String?
    var securityToken: String?

    init(userName: String,
         email: String,
         password: String,
         gravatarHash: String? = nil,
         name: String? = nil,
         bio: String? = nil,
         location: String? = nil,
         website: String? = nil,
         birthDate: Date? = nil,
         securityToken: String? = nil
    ) {
        self.userName = userName
        self.email = email
        self.password = password
        self.gravatarHash = gravatarHash
        self.name = name
        self.bio = bio
        self.location = location
        self.website = website
        self.birthDate = birthDate
        self.securityToken = securityToken
    }
}

extension RegisterUserDto: Content { }

extension RegisterUserDto: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("userName", as: String.self, is: .count(1...50) && .alphanumeric)
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(8...32) && .password)

        validations.add("name", as: String?.self, is: .count(...50) || .nil)
        validations.add("location", as: String?.self, is: .count(...50) || .nil)
        validations.add("website", as: String?.self, is: .count(...50) || .nil)
        validations.add("bio", as: String?.self, is: .count(...200) || .nil)

        validations.add("securityToken", as: String?.self, is: !.nil)
    }
}
