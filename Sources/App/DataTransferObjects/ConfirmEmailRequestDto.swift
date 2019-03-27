import Vapor

final class ConfirmEmailRequestDto {

    var id: UUID
    var confirmationGuid: String

    init(id: UUID, confirmationGuid: String) {
        self.id = id
        self.confirmationGuid = confirmationGuid
    }
}

extension ConfirmEmailRequestDto: Content { }
