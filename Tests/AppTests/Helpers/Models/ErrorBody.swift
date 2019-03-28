import Vapor

final class ErrorBody: Content {
    var error: Bool;
    var code: String;
    var reason: String;

    init(error: Bool, code: String, reason: String) {
        self.error = error
        self.code = code
        self.reason = reason
    }
}
