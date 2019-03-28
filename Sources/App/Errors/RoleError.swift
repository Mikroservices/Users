import Vapor
import ExtendedError

enum RoleError: String, Error {
    case roleWithCodeExists
}

extension RoleError: TerminateError {
    var status: HTTPResponseStatus {
        return .forbidden
    }

    var reason: String {
        switch self {
        case .roleWithCodeExists: return "Role with specified code already exists."
        }
    }

    var identifier: String {
        return "role"
    }

    var code: String {
        return self.rawValue
    }
}
