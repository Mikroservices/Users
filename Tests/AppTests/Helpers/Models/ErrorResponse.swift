import Vapor

class ErrorResponse {
    var error: ErrorBody;
    var status: HTTPResponseStatus;

    init(error: ErrorBody, status: HTTPResponseStatus) {
        self.error = error
        self.status = status
    }
}
