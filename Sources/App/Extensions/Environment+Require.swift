import Foundation
import Vapor

extension Environment {
    static func require(_ key: String) throws -> String {
        guard let value = get(key) else {
            throw Abort(.internalServerError, reason: "Missing environment variable for '\(key)'")
        }

        return value
    }
}
