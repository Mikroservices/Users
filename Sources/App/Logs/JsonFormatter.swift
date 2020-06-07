import Foundation
import Logging

public class JsonFormatter: LogFormatter {
    public var metadata = Logger.Metadata() {
        didSet {
            self.prettyMetadata = self.prettify(self.metadata)
        }
    }
    
    struct LogEntry: Codable {
        let timestamp: Date
        let level: String
        let label: String
        let metadata: String
        let message: String
    }
    
    private var prettyMetadata: String?
    private let jsonEncoder: JSONEncoder
    private let newLine = "\n".data(using: .utf8)!
    
    public init() {
        self.jsonEncoder = JSONEncoder()
        self.jsonEncoder.outputFormatting = .prettyPrinted
        self.jsonEncoder.dateEncodingStrategy = JSONEncoder.DateEncodingStrategy.iso8601
    }
    
    public func format(label: String,
                       level: Logger.Level,
                       message: Logger.Message,
                       metadata: Logger.Metadata?,
                       file: String, function: String, line: UInt) throws -> Data? {

        let prettyMetadata = metadata?.isEmpty ?? true
            ? self.prettyMetadata
            : self.prettify(self.metadata.merging(metadata!, uniquingKeysWith: { _, new in new }))
        
        let entry = LogEntry(timestamp: Date(),
                             level: level.name,
                             label: label,
                             metadata: prettyMetadata.map { " \($0)" } ?? "",
                             message: message.description)

        
        var data = try jsonEncoder.encode(entry)
        data.append(newLine)
        
        return data
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
