import Vapor
import ExtendedError

enum AuthClientError: String, Error {
    case incorrectAuthClientId
}

extension AuthClientError: TerminateError {
    var status: HTTPResponseStatus {
        return .badRequest
    }

    var reason: String {
        switch self {
        case .incorrectAuthClientId: return "Authentication client id is incorrect."
        }
    }

    var identifier: String {
        return "auth-client"
    }

    var code: String {
        return self.rawValue
    }
}
