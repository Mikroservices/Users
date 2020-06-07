import Foundation
import Logging

public class SingleLineFormatter: LogFormatter {
    public var metadata = Logger.Metadata() {
        didSet {
            self.prettyMetadata = self.prettify(self.metadata)
        }
    }
    
    private var prettyMetadata: String?
    
    public init() {
    }
    
    public func format(label: String,
                       level: Logger.Level,
                       message: Logger.Message,
                       metadata: Logger.Metadata?,
                       file: String, function: String, line: UInt) -> Data? {

        let prettyMetadata = metadata?.isEmpty ?? true
            ? self.prettyMetadata
            : self.prettify(self.metadata.merging(metadata!, uniquingKeysWith: { _, new in new }))

        let message = "\(self.timestamp()) [\(level.name)] (\(label)\(prettyMetadata.map { ", \($0)" } ?? "")): \(message)\n"
        return message.data(using: .utf8)
    }
    
    private func prettify(_ metadata: Logger.Metadata) -> String? {
        return !metadata.isEmpty ? metadata.map { "\($0)=\($1)" }.joined(separator: " ") : nil
    }
    
    private func timestamp() -> String {
        var buffer = [Int8](repeating: 0, count: 255)
        var timestamp = time(nil)
        let localTime = localtime(&timestamp)
        strftime(&buffer, buffer.count, "%Y-%m-%dT%H:%M:%S%z", localTime)
        return buffer.withUnsafeBufferPointer {
            $0.withMemoryRebound(to: CChar.self) {
                String(cString: $0.baseAddress!)
            }
        }
    }
}
