import Vapor

extension Validator where T == String {
    /// Validates whether a `String` is a valid password.
    ///
    ///     try validations.add(\.password, .password)
    ///
    public static var password: Validator<T> {
        return PasswordValidator().validator()
    }
}

// MARK: Private
/// Validates whether a string is a valid password.
fileprivate struct PasswordValidator: ValidatorType {
    /// See `ValidatorType`.
    public var validatorReadable: String {
        return "a valid password"
    }

    /// Creates a new `PasswordValidator`.
    public init() {}

    /// See `Validator`.
    public func validate(_ s: String) throws {
        guard
            let range = s.range(of: "^(?:(?=.*[a-z])(?:(?=.*[A-Z])(?=.*[\\d\\W])|(?=.*\\W)(?=.*\\d))|(?=.*\\W)(?=.*[A-Z])(?=.*\\d)).{8,}$", options: [.regularExpression, .caseInsensitive]),
            range.lowerBound == s.startIndex && range.upperBound == s.endIndex
        else {
            throw BasicValidationError("is not a valid password")
        }
    }
}
