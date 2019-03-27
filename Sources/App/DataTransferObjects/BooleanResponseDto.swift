import Vapor

final class BooleanResponseDto {

    var result: Bool

    init(_ result: Bool) {
        self.result = result
    }
}

extension BooleanResponseDto: Content { }
