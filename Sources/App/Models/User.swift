import FluentPostgreSQL
import Vapor

/// A single entry of a Voice list.
final class User: PostgreSQLUUIDModel {

    var id: UUID?
    var userName: String
    var email: String
    var name: String?
    var password: String
    var salt: String
    var emailWasConfirmed: Bool
    var isBlocked: Bool
    var emailConfirmationGuid: String
    var forgotPasswordGuid: String?
    var forgotPasswordDate: Date?
    var bio: String?
    var location: String?
    var website: String?
    var birthDate: Date?

    var userNameNormalized: String
    var emailNormalized: String
    var gravatarHash: String

    init(id: UUID? = nil,
         userName: String,
         email: String,
         name: String?,
         password: String,
         salt: String,
         emailWasConfirmed: Bool,
         isBlocked: Bool,
         emailConfirmationGuid: String,
         gravatarHash: String,
         forgotPasswordGuid: String? = nil,
         forgotPasswordDate: Date? = nil,
         bio: String? = nil,
         location: String? = nil,
         website: String? = nil,
         birthDate: Date? = nil
    ) {
        self.id = id
        self.userName = userName
        self.email = email
        self.name = name
        self.password = password
        self.salt = salt
        self.emailWasConfirmed = emailWasConfirmed
        self.isBlocked = isBlocked
        self.emailConfirmationGuid = emailConfirmationGuid
        self.gravatarHash = gravatarHash
        self.forgotPasswordGuid = forgotPasswordGuid
        self.forgotPasswordDate = forgotPasswordDate
        self.bio = bio
        self.location = location
        self.website = website
        self.birthDate = birthDate

        self.userNameNormalized = userName.uppercased()
        self.emailNormalized = email.uppercased()
        self.gravatarHash = gravatarHash
    }
}

/// Refresh tokens generated for user.
extension User {
    var refreshTokens: Children<User, RefreshToken> {
        return children(\.id)
    }
}

/// Roles connected to user.
extension User {
    var roles: Siblings<User, Role, UserRole> {
        return siblings()
    }
}

/// Allows `Voice` to be used as a dynamic migration.
extension User: Migration { }

/// Allows `Voice` to be encoded to and decoded from HTTP messages.
extension User: Content { }

/// Allows `Voice` to be used as a dynamic parameter in route definitions.
extension User: Parameter { }

extension User {
    convenience init(from registerUserDto: RegisterUserDto,
                     withPassword password: String,
                     salt: String,
                     emailConfirmationGuid: String,
                     gravatarHash: String) {
        self.init(
            userName: registerUserDto.userName,
            email: registerUserDto.email,
            name: registerUserDto.name,
            password: password,
            salt: salt,
            emailWasConfirmed: false,
            isBlocked: false,
            emailConfirmationGuid: emailConfirmationGuid,
            gravatarHash: gravatarHash,
            bio: registerUserDto.bio,
            location: registerUserDto.location,
            website: registerUserDto.website,
            birthDate: registerUserDto.birthDate
        )
    }

    func getUserName() -> String {
        guard let userName = self.name else {
            return self.userName
        }

        return userName
    }
}
