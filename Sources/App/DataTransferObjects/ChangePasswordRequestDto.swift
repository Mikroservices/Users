import Vapor

final class ChangePasswordRequestDto: Reflectable {

    var currentPassword: String
    var newPassword: String

    init(currentPassword: String, newPassword: String) {
        self.currentPassword = currentPassword
        self.newPassword = newPassword
    }
}

extension ChangePasswordRequestDto: Content { }

extension ChangePasswordRequestDto: Validatable {

    /// See `Validatable`.
    static func validations() throws -> Validations<ChangePasswordRequestDto> {
        var validations = Validations(ChangePasswordRequestDto.self)

        try validations.add(\.newPassword, .count(8...32))

        return validations
    }
}

