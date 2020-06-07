import Foundation
import Logging

public protocol LogFormatter {
    var metadata: Logger.Metadata { get set }

    func format(label: String,
                level: Logger.Level,
                message: Logger.Message,
                metadata: Logger.Metadata?,
                file: String,
                function: String,
                line: UInt) throws -> Data?
}
